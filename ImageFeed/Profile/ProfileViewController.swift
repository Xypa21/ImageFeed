//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 26.05.2025.
//


import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let logoutImage = UIImage (named: "NoAvatar")
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Avatar") ?? UIImage(systemName: "person.crop.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = UIColor(named: "YP White")
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "YP Gray")
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bioLabel: UILabel = {
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
        updateProfileDetails()
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else { return }
        
        nameLabel.text = profile.name
        loginLabel.text = profile.loginName
        bioLabel.text = profile.bio
        
        ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { [weak self] _ in
            self?.updateAvatar()
        }
    }
    
    private func updateAvatar() {
        guard let avatarURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: avatarURL) else { return }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Avatar"),
            options: [.processor(processor)]
        )
    }
    
    private func setupSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(bioLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            
            loginLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            bioLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            bioLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        ])
    }
    
    @objc
    private func didTapLogoutButton() {
        profileImageView.image = logoutImage
        for view in view.subviews {
            if view is UILabel {
                view.removeFromSuperview()
            }
        }
    }
}
