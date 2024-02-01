//
//  Data+Extension.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import Foundation
import Foundation
typealias JSON = [String: Any]
extension Data {
    func toJSON() -> JSON {
        var json: [String: Any] = [:]
        do {
            if let jsonObj = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as? JSON {
                json = jsonObj
            }
        } catch {
            print("JSON casting error")
        }
        return json
    }
}
