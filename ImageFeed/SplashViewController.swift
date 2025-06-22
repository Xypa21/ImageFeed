import UIKit
import SwiftKeychainWrapper
import Kingfisher

final class SplashViewController: UIViewController {
    private let oauth2Service = OAuth2Service.shared
    private let profileService = ProfileService.shared
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Vector"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SplashViewController loaded")
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            if self.oauth2Service.authToken != nil {
                self.fetchProfile(token: self.oauth2Service.authToken!)
            } else {
                self.showAuth()
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP Black")
        print("Setting up UI")
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 75),
            logoImageView.heightAnchor.constraint(equalToConstant: 77)
        ])
    }
    
    private func showAuth() {
        print("Показываем экран авторизации")
        let authVC = AuthViewController()
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true) {
            print("AuthViewController показан")
        }
    }
    
    private func fetchProfile(token: String) {
        print("Начинаем загрузку профиля...")
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let profile):
                    print("Профиль загружен: \(profile.username)")
                    self?.fetchAvatar(username: profile.username)
                case .failure(let error):
                    print("Ошибка загрузки профиля: \(error)")
                    self?.showAuth()
                }
            }
        }
    }
    
    private func fetchAvatar(username: String) {
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] _ in
            self?.switchToTabBar()
        }
    }
    
    private func switchToTabBar() {
        guard let window = UIApplication.shared.windows.first else {
            print("Ошибка: Не найдено окно приложения")
            return
        }
        
        let tabBarVC = TabBarController(nibName: nil, bundle: nil)
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = tabBarVC
            },
            completion: { _ in
                print("Переход завершен. Текущий контроллер: \(String(describing: window.rootViewController))")
                window.makeKeyAndVisible()
            }
        )
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = oauth2Service.authToken else { return }
        fetchProfile(token: token)
    }
}
