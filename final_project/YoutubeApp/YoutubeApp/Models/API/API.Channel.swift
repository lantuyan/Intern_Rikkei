//
//  APIManager.Channel.swift
//  YoutubeApp
//
//  Created by Admin on 08/01/2024.
//

import Foundation
extension APIManager.Channel {
    struct QueryString {
        let key = App.Key.apiKey
        let regionCode = "VN"
        let chart = "mostPopular"
        let part = "snippet,contentDetails,id,statistics"
        
        func getChannelUrl(channelId: String) -> String {
                return APIManager.Path.base_domain +
                    APIManager.Path.channel +
                    "?key=\(key)" +
                    "&id=\(channelId)" +
                    "&part=\(part)"
        }
        
        func getMyChannelUrl() -> String {
                return APIManager.Path.base_domain +
                    APIManager.Path.channel +
                    "?key=\(key)" +
                    "&mine=true" +
                    "&part=\(part)"
        }
    }
    
    static func getChannelInfo(channelId: String, completion: @escaping APICompletion<ChannelResult>) {
        let queryString = QueryString()
        let urlString = queryString.getChannelUrl(channelId: channelId)
        print(urlString)
        
        API.shared().request(urlString: urlString) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let data):
                if let data = data {
                    let json = data.toJSON()
                    guard let items = json["items"] as? [JSON] else {
                        return
                    }
                    if let firstItem = items.first, let channel = Channel(json: firstItem) {
                        let copyright = "copyright information"
                        let updated = "Update"
                        let channelResult = ChannelResult(channel: channel, copyright: copyright, update: updated)
                        completion(.success(channelResult))
                    } else {
                        completion(.failure(.error("Unable to extract channel information")))
                    }
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
    static func getMyChannelInfo(completion: @escaping APICompletion<ChannelResult>) {
        let queryString = QueryString()
        let urlString = queryString.getMyChannelUrl()
        print(urlString)
        
        API.shared().request(urlString: urlString, method: "GET"){ (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let data):
                if let data = data {
                    let json = data.toJSON()
                    guard let items = json["items"] as? [JSON] else {
                        return
                    }
                    if let firstItem = items.first, let channel = Channel(json: firstItem) {
                        let copyright = "copyright information"
                        let updated = "Update"
                        let channelResult = ChannelResult(channel: channel, copyright: copyright, update: updated)
                        completion(.success(channelResult))
                    } else {
                        completion(.failure(.error("Unable to extract channel information")))
                    }
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
    static func getChannelUrlImage(videoId: String, completion: @escaping (Result<String, APIError>) -> Void) {
           let queryString = QueryString()
           let urlString = queryString.getChannelUrl(channelId: videoId)
           API.shared().request(urlString: urlString) { (result) in
               switch result {
               case .failure(let error):
                   completion(.failure(error))

               case .success(let data):
                   if let data = data {
                       let json = data.toJSON()
                       let items = json["items"] as? [JSON]
                       if let firstItem = items?.first,
                            let channel = ChannelImageUrl(json: firstItem) {
                           completion(.success(channel.channelUrl))
                       } else {
                             completion(.failure(.error("Unable to extract channel information")))
                       }
                   } else {
                       completion(.failure(.error("Data is not formatted")))
                   }
               }
           }
    }
    
}
