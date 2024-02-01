//
//  Channel.swift
//  YoutubeApp
//
//  Created by Admin on 13/01/2024.
//

import Foundation

struct ChannelResult {
    var channel: Channel
    var copyright: String
    var update: String
}

struct Channel {
    let channelId: String
    let title: String
    let description: String
    let avatarChannelUrl: String
    let subscriberCount: String
}

extension Channel {
    init?(json: JSON) {
        guard
            let channelId = json["id"] as? String,
            let snippet = json["snippet"] as? JSON,
            let statistics = json["statistics"] as? JSON,
            let title = snippet["title"] as? String,
            let description = snippet["description"] as? String,
            let thumbnail = snippet["thumbnails"] as? JSON,
            let avatarUrl = (thumbnail["default"] as? [String: Any])?["url"] as? String,
            let subscriberCount = statistics["subscriberCount"] as? String
        else {
            return nil
        }

        self.channelId = channelId
        self.title = title
        self.description = description
        self.avatarChannelUrl = avatarUrl
        self.subscriberCount = subscriberCount
    }
}
