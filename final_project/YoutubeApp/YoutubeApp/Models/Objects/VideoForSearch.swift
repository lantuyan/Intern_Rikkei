//
//  VideoForSearch.swift
//  YoutubeApp
//
//  Created by Admin on 11/01/2024.
//

import Foundation
import UIKit

struct VideoResultForSearch {
    var videos: [VideoForSearch]
    var copyright: String
    var update: String
}

struct VideoForSearch {
    let videoId: String
    let title: String
    let description: String
    let publishedAt: String
    let thumbnailUrl: String
    let channelId: String
    let channelTitle: String
    var thumbnailImage: UIImage? // Add UIImage property
    var channelImageUrl: String?
    var channelImage: UIImage?
    var channel: Channel?
    
}

extension VideoForSearch {
    init?(json: JSON) {
        guard
            let snippet = json["snippet"] as? JSON,
            let id = json["id"] as? JSON,
            let videoId = id["videoId"] as? String,
            let title = snippet["title"] as? String,
            let description = snippet["description"] as? String,
            let publishedAt = snippet["publishedAt"] as? String,
            let thumbnail = snippet["thumbnails"] as? JSON,
            let channelTitle = snippet["channelTitle"] as? String,
            let channelId = snippet["channelId"] as? String,
            let thumbnailUrl = (thumbnail["medium"] as? [String: Any])?["url"] as? String
            
        else {
            return nil
        }

        self.videoId = videoId
        self.title = title
        self.description = description
        self.publishedAt = publishedAt
        self.thumbnailUrl = thumbnailUrl
        self.channelTitle = channelTitle
        self.channelId = channelId
        self.thumbnailImage = nil
        self.channelImage = nil
        self.channel = Channel(json: json)
        
    }
}
