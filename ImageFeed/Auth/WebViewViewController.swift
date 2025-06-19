//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 15.06.2025.
//
import WebKit
import UIKit


enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}


protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}


final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    
    
    @IBAction func tapBackButton() {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    
    @IBOutlet private var progressView: UIProgressView!
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    private var isAuthorizationInProgress = false
    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        webView.navigationDelegate = self
        setupProgressObservation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        estimatedProgressObservation?.invalidate()
        UIBlockingProgressHUD.dismiss()
    }
    
    private func setupProgressObservation() {
            estimatedProgressObservation = webView.observe(\.estimatedProgress, options: [], changeHandler: { [weak self] _, _ in
                guard let self = self else { return }
                self.updateProgress()
            })
        }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIBlockingProgressHUD.dismiss()
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
         if let code = code(from: navigationAction) {
             decisionHandler(.cancel)
             delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                         return
                     }
                     decisionHandler(.allow)
                 }
    
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }
        return codeItem.value
    }
    
    private func handleAuthCode(code: String) {
            guard !isAuthorizationInProgress else { return }
            
            isAuthorizationInProgress = true
            UIBlockingProgressHUD.show()
            
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
        }
}
