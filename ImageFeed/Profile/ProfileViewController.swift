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
