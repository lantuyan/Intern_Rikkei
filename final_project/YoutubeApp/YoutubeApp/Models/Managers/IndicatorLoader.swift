//
//  Ultil.swift
//  YoutubeApp
//
//  Created by Admin on 19/01/2024.
//

import Foundation
import UIKit
class IndicatorLoader {
    static let shared = IndicatorLoader()
    private var activityIndicator = UIActivityIndicatorView(style: .large)
    private init(){
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
    }
    
    func showActivityIndicator(on view: UIView) {
        DispatchQueue.main.async {
            self.activityIndicator.center = view.center
            view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
}
