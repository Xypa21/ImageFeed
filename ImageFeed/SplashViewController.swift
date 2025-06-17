//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//
import UIKit

final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2TokenStorage = OAuth2TokenStorage()

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
           
           let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
                guard
                    let navigationController = segue.destination as? UINavigationController,
                    let viewController = navigationController.viewControllers[0] as? AuthViewController
                else {
                    print("[SplashViewController] Failed to prepare for auth screen")
                    return
                }
                viewController.delegate = self
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }


extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        switchToTabBarController()
    }
}
