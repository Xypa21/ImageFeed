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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileImage = UIImageView()
        profileImage.image = UIImage (named: "Avatar")
        profileImage.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(profileImage)
        profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let nameLabel = UILabel()
                nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.systemFont(ofSize: 28)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8).isActive = true
                self.nameLabel = nameLabel
        
        let loginLabel = UILabel()
        loginLabel.text = "@ekaterina_nov"
        loginLabel.textColor = UIColor(named: "YP Gray")
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(loginLabel)
        loginLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor).isActive = true
        loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
                self.loginLabel = loginLabel
        
        let infoLabel = UILabel()
        infoLabel.text = "Hello, world!"
        infoLabel.textColor = UIColor(named: "YP White")
        infoLabel.font = UIFont.systemFont(ofSize: 13)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(infoLabel)
        infoLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor).isActive = true
        infoLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8).isActive = true
                self.infoLabel = infoLabel
        
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "LogoutButton")!,
            target: self,
            action: #selector(Self.didTapButton)
                )
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.tintColor = UIColor(named: "YP Red")
        logoutButton.imageView?.contentMode = .scaleAspectFit
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
    }
    
    @objc
    private func didTapButton() {
        for view in view.subviews {
            if view is UILabel {
            view.removeFromSuperview()
            }
        }
    }
}
