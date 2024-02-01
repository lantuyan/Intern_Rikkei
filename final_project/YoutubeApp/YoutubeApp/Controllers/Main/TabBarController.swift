//
//  TabBarController.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import UIKit
import SwiftUI

class TabBarController: UITabBarController {
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialConfiguration()
        setupTabs()
        setupLayout()
    }
    
    // MARK: - Setup
    private func setupInitialConfiguration() {
        self.delegate = self
    }
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        homeVC.delegate = self
        
        let home = createTab(with: "Home", image: UIImage(systemName: "house.fill"), viewController: homeVC)
        let search = createTab(with: "Search", image: UIImage(systemName: "magnifyingglass"), viewController: SearchViewController())
        let room = createTab(with: "Room", image: UIImage(systemName: "play.rectangle.on.rectangle"), viewController: RoomViewController())
        let profile = createTab(with: "Profile", image: UIImage(systemName: "person.fill"), viewController: ProfileViewController())
        
        setViewControllers([home, search, room, profile], animated: true)
        configureTabBarAppearance()
    }
    
    private func createTab(with title: String, image: UIImage?, viewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        configureNavigationBar(for: nav)
        return nav
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func configureNavigationBar(for navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        navigationController.navigationBar.backgroundColor = .white
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setupLayout() {
        tabBar.tintColor = UIColor.black
        tabBar.barTintColor = UIColor.white
        tabBar.backgroundColor = .white
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.gray.cgColor
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if selectedIndex == 0 {
            print("Home")
        }
    }
}

// MARK: - HomeViewControllerDelegate
extension TabBarController: HomeViewControllerDelegate {
    func switchToSearchTab() {
        selectedIndex = 1
    }
    
    func switchToProfileTab() {
        print("OK")
        selectedIndex = 3
    }
}
