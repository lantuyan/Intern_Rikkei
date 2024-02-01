//
//  DataManager.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import Foundation
import Foundation
import UIKit

class DataManager {
    private static var sharedDataManager: DataManager = {
        let dataManager = DataManager()
        return dataManager
    }()
    
    class func shared() -> DataManager {
        return sharedDataManager
    }
    
    private init(){}
    
    func getChannelFromUserDefaults() -> Channel? {
        let userDefaults = UserDefaults.standard
        guard
            let channelId = userDefaults.string(forKey: "channelId"),
            let title = userDefaults.string(forKey: "title"),
            let description = userDefaults.string(forKey: "description"),
            let avatarChannelUrl = userDefaults.string(forKey: "avatarChannelUrl"),
            let subscriberCount = userDefaults.string(forKey: "subscriberCount")
        else {
            // Handle the case when one or more values are not found
            return nil
        }
        let channel = Channel(
            channelId: channelId,
            title: title,
            description: description,
            avatarChannelUrl: avatarChannelUrl,
            subscriberCount: subscriberCount
        )
        
        return channel
    }
    
    func saveChannelToUserDefaults(channel: Channel) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(channel.channelId, forKey: "channelId")
        userDefaults.set(channel.title, forKey: "title")
        userDefaults.set(channel.description, forKey: "description")
        userDefaults.set(channel.avatarChannelUrl, forKey: "avatarChannelUrl")
        userDefaults.set(channel.subscriberCount, forKey: "subscriberCount")
        userDefaults.synchronize()
    }
}
