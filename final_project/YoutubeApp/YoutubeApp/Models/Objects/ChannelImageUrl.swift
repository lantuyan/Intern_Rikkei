//
//  Channel.swift
//  YoutubeApp
//
//  Created by Admin on 08/01/2024.
//

import Foundation
struct ChannelImageUrl {
    let channelId: String
    let channelUrl: String
    let subscriberCount: String
    
}

extension ChannelImageUrl {
    init?(json: JSON) {
        guard
            let channelId = json["id"] as? String,
            let snippet = json["snippet"] as? JSON,
            let statistics = json["statistics"] as? JSON,
            let thumbnail = snippet["thumbnails"] as? JSON,
            let channelUrl = (thumbnail["default"] as? [String: Any])?["url"] as? String,
            let subscriberCount = statistics["subscriberCount"] as? String
        else {
            return nil
        }

               
        self.channelId = channelId
        self.channelUrl = channelUrl
        self.subscriberCount = subscriberCount
    }
}
