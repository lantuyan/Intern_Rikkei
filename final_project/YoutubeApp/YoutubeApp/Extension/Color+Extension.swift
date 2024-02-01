//
//  Color+Extension.swift
//  YoutubeApp
//
//  Created by Admin on 08/01/2024.
//

import Foundation
import UIKit

extension UIColor {
    static let primary = UIColor (red: 0.33, green: 0.69, blue: 0.46, alpha: 1.00)
    static let description = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 0.7)
    static let darkbackground = UIColor(red: 108, green: 11, blue: 1, alpha: 1)
    
    static let color1 = UIColor(hex: "3b3b3b")
    static let color2 = UIColor(hex: "ececec")
    
    static let blackdarkColor1 = UIColor(hex: "3B3B3B")
    static let blackdarkColor2 = UIColor(hex: "6C6C6C")
    static let blackdarkColor3 = UIColor(hex: "9D9D9D")
    static let blackdarkColor4 = UIColor(hex: "CECECE")
    static let blackdarkColor5 = UIColor(hex: "ECECEC")
    static let blackdarkColor6 = UIColor(hex: "3B3B3B")
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
