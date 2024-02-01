//
//  SceneDelegate.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import UIKit
import GoogleSignIn
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.makeKeyAndVisible()
        
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // User is already signed in
            changeScreen(type: .main)
        } else {
            print("User not signed in")
            changeScreen(type: .login)
        }
    }
    
    func changeScreen(type: TypeScreen) {
        switch type {
        case .onboarding:
            createOnboardingScreen()
        case .login:
            createLoginScreen()
        case .main:
            createMainScreen()
        }
    }
    
    private func createOnboardingScreen() {
        let welcomeVC = UIViewController()
        let welcomeNavigation = UINavigationController(rootViewController: welcomeVC)
        window?.rootViewController = welcomeNavigation
    }
    private func createMainScreen() {
        let mainVC = TabBarController()
        window?.rootViewController = mainVC
    }
    
    private func createLoginScreen(){
        let loginVC = SignInViewController()
        window?.rootViewController = loginVC
    }
}

enum TypeScreen {
    case login
    case main
    case onboarding
}

extension SceneDelegate {
    // MARK: - Life cycle app
    func sceneDidDisconnect(_ scene: UIScene) {
        print(" disconnect")
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
//        print("sceneDidBecomeActive")
//        if NetworkMonitor.shared.isConected {
//            AlertManager.shared.hideAlertMessage(viewController: self.window?.rootViewController ?? UIViewController())
//            print("You're connteced")
//        } else {
//            AlertManager.shared.showAlertMessage(title: "Alert", message: "No Internet, please connect wifi or 4g", viewController: self.window?.rootViewController ?? UIViewController())
//            print("Don't have internet")
//        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print(" sceneWillResignActive")
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("ENTER ForeGround")
    }
    
    //    func sceneDidEnterBackground(_ scene: UIScene) {
    //    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("ENTER Background")
        
        guard let rootViewController = window?.rootViewController as? UITabBarController else {
            return
        }
        
        print("Root view controller is \(rootViewController)")
        print("It has \(rootViewController.viewControllers?.count ?? 0) child/children viewControllers")
        
        // Iterate through each tab in the UITabBarController
        for (index, viewController) in (rootViewController.viewControllers ?? []).enumerated() {
            print("Tab \(index + 1): \(viewController)")
            
            // Check if the view controller is a UINavigationController
            if let navController = viewController as? UINavigationController,
               let topViewController = navController.topViewController,
               topViewController is RoomDetailViewController {
                
                // Dismiss RoomDetailViewController
                navController.popViewController(animated: false)
                
                // Check if the current top view controller is RoomViewController
                if let newTopViewController = navController.topViewController, newTopViewController is RoomViewController {
                    // Handle any additional actions you want to perform after returning to RoomVC
                }
            }
        }
    }


}

