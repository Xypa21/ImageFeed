//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сёма Шибаев on 22.06.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let imagesListVC = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            fatalError("Не удалось загрузить ImagesListViewController из Storyboard")
        }
        
        let profileVC = ProfileViewController()
        
        imagesListVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_editorial_active"),
            tag: 0
        )
        
        profileVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            tag: 1
        )
        
        self.viewControllers = [imagesListVC, profileVC]
        print("Контроллеры успешно установлены: \(self.viewControllers?.count ?? 0)")
    }
    
    private func setupTabBarAppearance() {
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            appearance.backgroundColor = UIColor(named: "YP Black")
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "YP Gray")
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "YP White")
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = UIColor(named: "YP Black")
            tabBar.tintColor = UIColor(named: "YP White")
            tabBar.unselectedItemTintColor = UIColor(named: "YP Gray")
        }
        
        tabBar.removeConstraints(tabBar.constraints)
        
        let height: CGFloat = 83
        tabBar.heightAnchor.constraint(equalToConstant: height).isActive = true
        tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func adjustTabBarItems() {
        
            let verticalOffset: CGFloat = 10
        tabBar.items?.forEach {
            $0.imageInsets = UIEdgeInsets(
                top: verticalOffset,
                left: 0,
                bottom: -verticalOffset,
                right: 0
            )
        }
        let tabItem = UIView()
        tabItem.translatesAutoresizingMaskIntoConstraints = false
        let activeTabItem = UIView()
                activeTabItem.backgroundColor = .systemBlue
                tabItem.addSubview(activeTabItem)
        activeTabItem.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                        activeTabItem.widthAnchor.constraint(equalToConstant: 30),
                        activeTabItem.heightAnchor.constraint(equalToConstant: 30),
                        activeTabItem.topAnchor.constraint(equalTo: tabItem.topAnchor, constant: 14),
                        activeTabItem.leadingAnchor.constraint(equalTo: tabItem.leadingAnchor, constant: 83)
                ])
        }
    }

