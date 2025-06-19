//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 16.06.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = oauth2TokenStorage.token {
                    loadProfile(token: token)
                } else {
                    showAuthScreen()
                }
        }
    
    private func showAuthScreen() {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func loadProfile(token: String) {
            UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
                    DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                    
                        switch result {
                    case .success:
                            self?.fetchProfileImage(username: profile.username)
                        self?.switchToTabBarController()
                    case .failure:
                        print ("Ошибка получения информации профиля")
                        self?.showAuthScreen()
                }
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
            profileImageService.fetchProfileImageURL(username: username) { result in
                switch result {
                case .success(let avatarURL):
                    print("Successfully fetched avatar URL: \(avatarURL)")
                case .failure(let error):
                    print("Failed to fetch avatar URL: \(error.localizedDescription)")
                }
            }
        }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
}


extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
               }
            viewController.delegate = self
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = oauth2TokenStorage.token else {
            showAuthScreen()
            return
        }
    }
}

