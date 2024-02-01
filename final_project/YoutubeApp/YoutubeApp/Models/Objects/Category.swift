//
//  Category.swift
//  YoutubeApp
//
//  Created by Admin on 09/01/2024.
//

import Foundation
struct Category {
    let categoryId: String
    let title: String
    let assignable: Bool
    
}
extension Category {
    init?(json: JSON) {
        guard
            let categoryId = json["id"] as? String,
            let snippet = json["snippet"] as? JSON,
            let title = snippet["title"] as? String,
            let assignable = snippet["assignable"] as? Bool
        else {
            return nil
        }
        self.categoryId = categoryId
        self.title = title
        self.assignable = assignable
    }
   
}
       
  
