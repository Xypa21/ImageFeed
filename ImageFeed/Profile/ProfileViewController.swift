//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 26.05.2025.
//


import UIKit


final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var loginLabel: UILabel?
    private var infoLabel: UILabel?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profileImageService = ProfileService.shared
    
    private let profileImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Avatar") ?? UIImage(systemName: "person.crop.circle")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 35
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
    
    private let NameLabel: UILabel = {
            let label = UILabel()
            label.text = "Екатерина Новикова"
            label.textColor = UIColor(named: "YP White")
            label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
    private let LoginLabel: UILabel = {
            let label = UILabel()
            label.text = "@ekaterina_nov"
            label.textColor = UIColor(named: "YP Gray")
            label.font = UIFont.systemFont(ofSize: 13)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
    private let InfoLabel: UILabel = {
            let label = UILabel()
            label.text = "Hello, world!"
            label.textColor = UIColor(named: "YP White")
            label.font = UIFont.systemFont(ofSize: 13)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
    
    private lazy var logoutButton: UIButton = {
            let button = UIButton.systemButton(
                with: UIImage(named: "LogoutButton") ?? UIImage(systemName: "arrow.backward")!,
                target: self,
                action: #selector(didTapLogoutButton)
            )
            button.translatesAutoresizingMaskIntoConstraints = false
            button.tintColor = UIColor(named: "YP Red")
            button.imageView?.contentMode = .scaleAspectFit
            return button
        }()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = UIColor(named: "YP Black")
            setupSubviews()
            setupConstraints()
            loadProfileData()
            setupObserver()
        }
    
    private func setupSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(NameLabel)
        view.addSubview(LoginLabel)
        view.addSubview(InfoLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            NameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            NameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            LoginLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            LoginLabel.topAnchor.constraint(equalTo: NameLabel.bottomAnchor, constant: 8),
            
            InfoLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            InfoLabel.topAnchor.constraint(equalTo: LoginLabel.bottomAnchor, constant: 8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    private func loadProfileData() {
            guard let token = OAuth2TokenStorage().token else {
                print("No token available")
                return
            }
            
            UIBlockingProgressHUD.show()
            ProfileService.shared.fetchProfile(token) { [weak self] result in
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    
                    switch result {
                    case .success(let profile):
                        self?.updateProfileDetails(profile: profile)
                        self?.fetchProfileImage(username: profile.username)
                    case .failure(let error):
                        print("Failed to fetch profile: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        private func updateProfileDetails(profile: ProfileService.Profile) {
            nameLabel?.text = profile.name
            loginLabel?.text = profile.loginName
            infoLabel?.text = profile.bio
        }
        
        private func fetchProfileImage(username: String) {
            profileImageService.fetchProfileImageURL(username: username) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateAvatar()
                }
            }
        }
        
        private func setupObserver() {
            profileImageServiceObserver = NotificationCenter.default.addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
        }
        
        private func updateAvatar() {
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
            
            let processor = RoundCornerImageProcessor(cornerRadius: 35)
            profileImageView.kf.indicatorType = .activity
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Avatar"),
                options: [.processor(processor)]
            )
        }
    
    @objc
    private func didTapLogoutButton() {
        performLogout()
    }
    
    private func performLogout() {
            OAuth2TokenStorage().token = nil
            ProfileService.shared.clean()
            ProfileImageService.shared.clean()
          
            guard let window = UIApplication.shared.windows.first else {
                fatalError("Invalid configuration")
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            window.rootViewController = storyboard.instantiateInitialViewController()
    }
}
