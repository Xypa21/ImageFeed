//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//
import UIKit

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let oauth2Service = OAuth2Service.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthStatus()
    }

    private func checkAuthStatus() {
            if let token = oauth2TokenStorage.token, !token.isEmpty {
                validateToken(token)
            } else {
                showAuthController()
            }
        }
    
    private func validateToken(_ token: String) {
            switchToTabBarController()
        }
    
    private func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let authVC = storyboard.instantiateViewController(
                    withIdentifier: "AuthViewController"
                ) as? AuthViewController else { return }
                
                authVC.delegate = self
                authVC.modalPresentationStyle = .fullScreen
                present(authVC, animated: true)
            }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            print("Invalid window configuration")
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController")
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
            window.rootViewController = tabBarVC
        })
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
                guard
                    let navigationController = segue.destination as? UINavigationController,
                    let viewController = navigationController.viewControllers[0] as? AuthViewController
                else {
                    print("Failed to prepare for auth screen")
                    return
                }
                viewController.delegate = self
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }


extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            self?.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.switchToTabBarController()
                case .failure:
                    self?.showAuthController()
                }
            }
        }
    }
}
