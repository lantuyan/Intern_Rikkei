//
//  ErrorMessage.swift
//  YoutubeApp
//
//  Created by Admin on 19/01/2024.
//

import Foundation
import UIKit

class ErrorMessageManager {
    static let shared = ErrorMessageManager()
    private var errorMessageLabel: UILabel?
    private var errorImageView: UIImageView?
    private var actionButton: UIButton?
    private weak var scrollView: UIScrollView?
    
    private init() {}
    
    func showErrorMessage(_ message: String, on view: UIView, scrollView: UIScrollView?) {
        DispatchQueue.main.async {
            self.scrollView = scrollView
            scrollView?.isScrollEnabled = false  // Disable scrolling
            
            // Create error label if not exists
            if self.errorMessageLabel == nil {
                let label = UILabel()
                label.textColor = .red
                label.textAlignment = .center
                label.clipsToBounds = true
                label.numberOfLines = 0
                self.errorMessageLabel = label
            }
            
            // Create error image view if not exists
            if self.errorImageView == nil {
                let imageView = UIImageView(image: UIImage(named: "error-error_symbol"))
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = .red
                self.errorImageView = imageView
            }
            
            // Create action button if not exists
            if self.actionButton == nil {
                let button = UIButton(type: .system)
                button.setTitle("Retry", for: .normal)
                button.addTarget(self, action: #selector(self.retryButtonTapped), for: .touchUpInside)
                self.actionButton = button
            }
            
            guard let errorMessageLabel = self.errorMessageLabel,
                  let errorImageView = self.errorImageView,
                  let actionButton = self.actionButton else { return }
            
            // Set error message
            errorMessageLabel.text = message
            
            // Configure constraints for error label
            errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(errorMessageLabel)
            
            NSLayoutConstraint.activate([
                errorMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
                errorMessageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
                errorMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
            ])
            
            // Configure constraints for error image view
            errorImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(errorImageView)
            
            NSLayoutConstraint.activate([
                errorImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                errorImageView.bottomAnchor.constraint(equalTo: errorMessageLabel.topAnchor, constant: -10),
                errorImageView.widthAnchor.constraint(equalToConstant: 50),
                errorImageView.heightAnchor.constraint(equalToConstant: 50)
            ])
            
            // Configure constraints for action button
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(actionButton)
            
            NSLayoutConstraint.activate([
                actionButton.topAnchor.constraint(equalTo: errorMessageLabel.bottomAnchor, constant: 10),
                actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
    }
    
    @objc private func retryButtonTapped() {
        // Implement the action to be taken on button tap (retry, dismiss, etc.)
        // You can customize this based on your requirements
        // For example, you might want to trigger a retry action here
        print("Retry button tapped")
    }
    
    func hideErrorMessage() {
        DispatchQueue.main.async {
            self.scrollView?.isScrollEnabled = true  // Enable scrolling
            
            // Remove subviews and reset references
            self.errorMessageLabel?.removeFromSuperview()
            self.errorMessageLabel = nil
            
            self.errorImageView?.removeFromSuperview()
            self.errorImageView = nil
            
            self.actionButton?.removeFromSuperview()
            self.actionButton = nil
            
            self.scrollView = nil
        }
    }
}
