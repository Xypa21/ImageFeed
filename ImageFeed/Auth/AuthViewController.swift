//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 15.06.2025.
//
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
    }

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    weak var delegate: AuthViewControllerDelegate?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showWebViewSegueIdentifier {
                guard let webViewViewController = segue.destination as? WebViewViewController else {
                    assertionFailure("Failed to cast destination as WebViewViewController")
                    return
                }
                webViewViewController.delegate = self
            }
        }
    }

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
