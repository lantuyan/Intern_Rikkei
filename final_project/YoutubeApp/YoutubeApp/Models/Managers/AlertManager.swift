//
//  AlertManager.swift
//  YoutubeApp
//
//  Created by Admin on 25/01/2024.
//

import Foundation
import UIKit
class AlertManager {
    static let shared = AlertManager()
    
    private init() {}
    
    func showAlertMessage(title: String="Alert", message: String="This feature in developing", viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func hideAlertMessage(viewController: UIViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func showPasswordInputDialog(on viewController: UIViewController, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "Enter Password", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(nil)
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let passwordTextField = alertController.textFields?.first else {
                completion(nil)
                return
            }
            
            completion(passwordTextField.text)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
