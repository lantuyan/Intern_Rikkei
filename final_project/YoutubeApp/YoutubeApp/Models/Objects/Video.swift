//
//  Video.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import Foundation
import UIKit

struct VideoResult {
    var videos: [Video]
    var copyright: String
    var update: String
}

struct Video {
    let videoId: String
    let title: String
    let description: String
    let publishedAt: String
    let thumbnailUrl: String
    let viewCount: String
    let likeCount: String
    let commentCount: String
    let channelId: String
    let channelTitle: String
    let tags: [String]?
    let duration: String
    var thumbnailImage: UIImage? // Add UIImage property
    var channelImageUrl: String?
    var channelImage: UIImage?
    var channel: Channel?
    
}

extension Video {
    init?(json: JSON) {
        guard
            let snippet = json["snippet"] as? JSON,
            let contentDetails = json["contentDetails"] as? JSON,
            let statistics = json["statistics"] as? JSON,
            let videoId = json["id"] as? String,
            let title = snippet["title"] as? String,
            let description = snippet["description"] as? String,
            let publishedAt = snippet["publishedAt"] as? String,
            let thumbnail = snippet["thumbnails"] as? JSON,
            let channelTitle = snippet["channelTitle"] as? String,
            let channelId = snippet["channelId"] as? String,
            let thumbnailUrl = (thumbnail["medium"] as? [String: Any])?["url"] as? String,
            let duration = contentDetails["duration"] as? String,
            let viewCount = statistics["viewCount"] as? String,
            let likeCount = statistics["likeCount"] as? String,
            let commentCount = statistics["commentCount"] as? String
            
        else {
            return nil
        }

        self.videoId = videoId
        self.title = title
        self.description = description
        self.publishedAt = publishedAt
        self.thumbnailUrl = thumbnailUrl
        self.viewCount = viewCount
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.channelTitle = channelTitle
        self.channelId = channelId
        self.duration = duration

        // Check if "tags" is present, if not, set it to an empty array
        if let tags = snippet["tags"] as? [String] {
            self.tags = tags
        } else {
            self.tags = nil
        }

        self.thumbnailImage = nil
        self.channelImage = nil
        self.channel = Channel(json: json)
    }
}


