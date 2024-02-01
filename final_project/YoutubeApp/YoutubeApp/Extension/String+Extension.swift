//
//  String+Extension.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import Foundation
import UIKit
enum Process {
    case encode
    case decode
}
extension String {
    var trimmed: String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    func base64(_ method: Process) -> String? {
        switch method {
        case .encode:
            guard let data = data(using: .utf8) else { return nil }
            return data.base64EncodedString()
        case .decode:
            guard let data = Data(base64Encoded: self) else { return nil }
            return String(data: data, encoding: .utf8)
        }
    }
}
extension String {
    /// Initializes an NSURL object with a provided URL string. (read-only)
    var url: URL? {
        return URL(string: self)
    }
    /// The host, conforming to RFC 1808. (read-only)
    var host: String {
        if let url = url, let host = url.host {
            return host
        }
        return ""
    }
}
// MARK: - convert date, views, duration
extension String {
    func timeAgoSinceDate(currentDate: Date = Date()) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.timeZone = TimeZone(identifier: "UTC")

            guard let date = dateFormatter.date(from: self) else {
                // Handle invalid date string
                return "Invalid date format"
            }

            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: currentDate)

            guard let years = components.year, years > 0 else {
                guard let months = components.month, months > 0 else {
                    guard let days = components.day, days > 0 else {
                        guard let hours = components.hour, hours > 0 else {
                            guard let minutes = components.minute, minutes > 0 else {
                                // Less than a minute ago
                                return "Just now"
                            }
                            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
                        }
                        return "\(hours) hour\(hours == 1 ? "" : "s") ago"
                    }
                    return "\(days) day\(days == 1 ? "" : "s") ago"
                }
                return "\(months) month\(months == 1 ? "" : "s") ago"
            }
            return "\(years) year\(years == 1 ? "" : "s") ago"
    }
    
    func formattedViews() -> String {
           let count = Int(self) ?? 0
           let billion = 1_000_000_000
           let million = 1_000_000
           
           if count >= billion {
               let formattedCount = Double(count) / Double(billion)
               let formattedString = String(format: "%.1fB", formattedCount)
               return formattedString + " views"
           } else if count >= million {
               let formattedCount = Double(count) / Double(million)
               let formattedString = String(format: "%.1fM", formattedCount)
               return formattedString + " views"
           } else if count >= 1000 {
               let formattedCount = Double(count) / 1000.0
               let formattedString = String(format: "%.1fK", formattedCount)
               return formattedString + " views"
           } else {
               return "\(count) views"
           }
    }
    
    func formattedCounts() -> String {
           let count = Int(self) ?? 0
           let billion = 1_000_000_000
           let million = 1_000_000
           
           if count >= billion {
               let formattedCount = Double(count) / Double(billion)
               let formattedString = String(format: "%.1fB", formattedCount)
               return formattedString
           } else if count >= million {
               let formattedCount = Double(count) / Double(million)
               let formattedString = String(format: "%.1fM", formattedCount)
               return formattedString
           } else if count >= 1000 {
               let formattedCount = Double(count) / 1000.0
               let formattedString = String(format: "%.1fK", formattedCount)
               return formattedString
           } else {
               return "\(count)"
           }
    }
    
    func formattedSubcribe() -> String {
        let count = Int(self) ?? 0
        let billion = 1_000_000_000
        let million = 1_000_000
        
        if count >= billion {
            let formattedCount = Double(count) / Double(billion)
            let formattedString = String(format: "%.1fB", formattedCount)
            return formattedString + " subcribe"
        } else if count >= million {
            let formattedCount = Double(count) / Double(million)
            let formattedString = String(format: "%.1fM", formattedCount)
            return formattedString + " subcribe"
        } else if count >= 1000 {
            let formattedCount = Double(count) / 1000.0
            let formattedString = String(format: "%.1fK", formattedCount)
            return formattedString + " subcribe"
        } else {
            return "\(count) subcribe"
        }
    }
    
    func getYoutubeFormattedDuration() -> String {
            let formattedDuration = self.replacingOccurrences(of: "PT", with: "")
                .replacingOccurrences(of: "H", with: ":")
                .replacingOccurrences(of: "M", with: ":")
                .replacingOccurrences(of: "S", with: "")

            let components = formattedDuration.components(separatedBy: ":")

            var hours = "00"
            var minutes = "00"
            var seconds = "00"

            if components.count == 1 {
                seconds = components[0]
            } else if components.count == 2 {
                minutes = components[0]
                seconds = components[1]
            } else if components.count == 3 {
                hours = components[0]
                minutes = components[1]
                seconds = components[2]
            }

            // Ensure that minutes and seconds have two digits
            minutes = String(format: "%02d", Int(minutes) ?? 0)
            seconds = String(format: "%02d", Int(seconds) ?? 0)

            // If hours are zero, exclude them from the result
            return hours == "00" ? "\(minutes):\(seconds)" : "\(hours):\(minutes):\(seconds)"
    }
    
}

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 14 }
    var boldFont:UIFont { return UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont.systemFont(ofSize: fontSize)}
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    /* Other styling methods */
    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.orange
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func blackHighlight(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .foregroundColor : UIColor.white,
            .backgroundColor : UIColor.black
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func underlined(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font :  normalFont,
            .underlineStyle : NSUnderlineStyle.single.rawValue
            
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}
