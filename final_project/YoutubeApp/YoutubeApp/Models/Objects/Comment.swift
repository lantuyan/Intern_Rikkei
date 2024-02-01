//
//  Comment.swift
//  YoutubeApp
//
//  Created by Admin on 13/01/2024.
//

import Foundation
import UIKit
struct CommentsResult {
    var comments: [Comment]
    var copyright: String
    var nextPageToken: String
}

struct Comment {
    let commentId: String
    let textDisplay: String
    let textOriginal: String
    let authorDisplayName: String
    let authorProfileImageUrl: String
    let authorChannelId: String
    let likeCount: Int
    let publishedAt: String
    let updatedAt: String
    let totalReplyCount: Int
    let replies: [Reply]?
    
    var firstAvatarImageView: UIImage?
    
    
}

extension Comment {
    init?(json: JSON) {
        guard
            let commentId = json["id"] as? String,
            let snippet = json["snippet"] as? JSON,
            let topLevelComment = snippet["topLevelComment"] as? JSON,
            let totalReplyCount = snippet["totalReplyCount"] as? Int,
            let snippet2 = topLevelComment["snippet"] as? JSON,
            
            let textOriginal = snippet2["textOriginal"] as? String,
            let textDisplay = snippet2["textDisplay"] as? String,
            let authorDisplayName = snippet2["authorDisplayName"] as? String,
            let authorProfileImageUrl = snippet2["authorProfileImageUrl"] as? String,
            let authorChannelId = (snippet2["authorChannelId"] as? [String: Any])?["value"] as? String,
            let likeCount = snippet2["likeCount"] as? Int,
            let publishedAt = snippet2["publishedAt"] as? String,
            let updatedAt = snippet2["updatedAt"] as? String
            
        else {
            return nil
        }
        
        // Parse replies
        if let repliesData = json["replies"] as? JSON,
            let commentsData = repliesData["comments"] as? [JSON] {
            var repliesArray = [Reply]()
            for replyData in commentsData {
                if let reply = Reply(json: replyData) {
                    repliesArray.append(reply)
                }
            }
            self.replies = repliesArray
        } else {
            self.replies = []
        }
        

        self.commentId = commentId
        self.textDisplay = textDisplay
        self.textOriginal = textOriginal
        self.authorDisplayName = authorDisplayName
        self.authorProfileImageUrl = authorProfileImageUrl
        self.authorChannelId = authorChannelId
        self.likeCount = likeCount
        self.publishedAt = publishedAt
        self.updatedAt = updatedAt
        self.totalReplyCount = totalReplyCount
     
        
    }
}


struct Reply {
    let replyId: String
    let textDisplay: String
    let authorDisplayName: String
    let authorProfileImageUrl: String
    let authorChannelId: String
    let likeCount: Int
    let publishedAt: String
    let updatedAt: String
    var firstAvatarImageView: UIImage?

    init?(json: JSON) {
        guard
            let replyId = json["id"] as? String,
            let snippet = json["snippet"] as? JSON,
            let textDisplay = snippet["textDisplay"] as? String,
            let authorDisplayName = snippet["authorDisplayName"] as? String,
            let authorProfileImageUrl = snippet["authorProfileImageUrl"] as? String,
            let authorChannelId = (snippet["authorChannelId"] as? [String: Any])?["value"] as? String,
            let likeCount = snippet["likeCount"] as? Int,
            let publishedAt = snippet["publishedAt"] as? String,
            let updatedAt = snippet["updatedAt"] as? String
        else {
            return nil
        }

        self.replyId = replyId
        self.textDisplay = textDisplay
        self.authorDisplayName = authorDisplayName
        self.authorProfileImageUrl = authorProfileImageUrl
        self.authorChannelId = authorChannelId
        self.likeCount = likeCount
        self.publishedAt = publishedAt
        self.updatedAt = updatedAt
    }
}

