//
//  UIImageView+Extension.swift
//  YoutubeApp
//
//  Created by Admin on 08/01/2024.
//

import Foundation
import UIKit
extension UIImageView {
    func makeRounded() {
           layer.masksToBounds = false
           layer.cornerRadius = self.frame.height / 2
           clipsToBounds = true
       }
}

extension UIImage {
    func resizedImage(with size: CGSize) -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            defer { UIGraphicsEndImageContext() }
            draw(in: CGRect(origin: .zero, size: size))
            return UIGraphicsGetImageFromCurrentImageContext()
    }
}
