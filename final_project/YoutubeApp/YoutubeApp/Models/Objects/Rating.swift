//
//  Rating.swift
//  YoutubeApp
//
//  Created by Admin on 23/01/2024.
//

import Foundation
struct RatingResult {
    var ratings: [Rating]
    var copyright: String
}

struct Rating {
    let videoId: String
    let rating: String

}

extension Rating {
    init?(json: JSON) {
        guard
            let videoId = json["videoId"] as? String,
            let rating = json["rating"] as? String
    
        else {
            return nil
        }

        self.videoId = videoId
        self.rating = rating
 
    }
}

