//
//  Subscription.swift
//  YoutubeApp
//
//  Created by Admin on 17/01/2024.
//
import Foundation
import UIKit
struct SubscriptionsResult {
    var subscriptions: [Subscription]
    var copyright: String
    var update: String
}
struct SubscriptionResult {
    var subcription: Subscription?
    var isSubribe: Bool
}

struct Subscription {
    let id: String
    let channelId: String
    let title: String
    let description: String
    let avatarChannelUrl: String
    var thumbnailImage: UIImage? // Add UIImage property
}

extension Subscription {
    init?(json: JSON) {
        guard
            let id = json["id"] as? String,
            let snippet = json["snippet"] as? JSON,
            let title = snippet["title"] as? String,
            let description = snippet["description"] as? String,
            let resourceId = snippet["resourceId"] as? JSON,
            let channelId = resourceId["channelId"] as? String,
            let thumbnail = snippet["thumbnails"] as? JSON,
            let avatarUrl = (thumbnail["default"] as? [String: Any])?["url"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.channelId = channelId
        self.title = title
        self.description = description
        self.avatarChannelUrl = avatarUrl
    }
}
