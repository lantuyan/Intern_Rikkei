//
//  DataVideo.swift
//  YoutubeApp
//
//  Created by Admin on 13/01/2024.
//

import Foundation
import RealmSwift

class DataVideo: Object {
    @objc dynamic var videoId: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var videoDescription: String = ""
    @objc dynamic var publishedAt: String = ""
    @objc dynamic var thumbnailUrl: String = ""
    @objc dynamic var viewCount: String = ""
    @objc dynamic var likeCount: String = ""
    @objc dynamic var commentCount: String = ""
    @objc dynamic var channelId: String = ""
    @objc dynamic var channelTitle: String = ""
    @objc dynamic var duration: String = ""
    @objc dynamic var thumbnailImageData: Data? = nil
    @objc dynamic var channelImageUrl: String? = nil
    @objc dynamic var channelImage: Data? = nil
    @objc dynamic var channel: DataChannel? = nil
    
    @objc dynamic var isLiked: Bool = false
    @objc dynamic var isDisliked: Bool = false
    @objc dynamic var isSaved: Bool = false
    
    @objc dynamic var lastUpdated = Date.now
    

    convenience init(video: Video) {
        self.init()
        self.videoId = video.videoId
        self.title = video.title
        self.videoDescription = video.description
        self.publishedAt = video.publishedAt
        self.thumbnailUrl = video.thumbnailUrl
        self.viewCount = video.viewCount
        self.likeCount = video.likeCount
        self.commentCount = video.commentCount
        self.channelId = video.channelId
        self.channelTitle = video.channelTitle
        self.duration = video.duration
        self.thumbnailImageData = video.thumbnailImage?.pngData()
        self.channelImageUrl = video.channelImageUrl
        self.channelImage = video.channelImage?.pngData()

        if let channel = video.channel {
            self.channel = DataChannel(channel: channel)
        }
    }
}

class DataChannel: Object {
    @objc dynamic var channelId: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var channelDescription: String = ""
    @objc dynamic var avatarChannelUrl: String = ""
    @objc dynamic var subscriberCount: String = ""

    convenience init(channel: Channel) {
        self.init()
        self.channelId = channel.channelId
        self.title = channel.title
        self.channelDescription = channel.description
        self.avatarChannelUrl = channel.avatarChannelUrl
        self.subscriberCount = channel.subscriberCount
    }
}

