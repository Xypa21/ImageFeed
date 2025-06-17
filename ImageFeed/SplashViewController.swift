//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//
import UIKit

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
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
               print("[SplashViewController] Invalid window configuration")
               return
           }
           
           let storyboard = UIStoryboard(name: "Main", bundle: .main)
           guard let tabBarController = storyboard.instantiateViewController(
               withIdentifier: "TabBarViewController"
           ) as? UITabBarController else {
               print("[SplashViewController] Failed to instantiate TabBarViewController")
               return
           }
           
           window.rootViewController = tabBarController
       }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
                guard
                    let navigationController = segue.destination as? UINavigationController,
                    let viewController = navigationController.viewControllers.first as? AuthViewController
                else {
                    print("[SplashViewController] Failed to prepare for auth screen")
                    return
                }
                viewController.delegate = self
            }
        }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            switch result {
            case .success:
                self?.switchToTabBarController()
            case .failure(let error):
                print("Auth failed: \(error.localizedDescription)")
            }
        }
    }
}
