//
//  API.Subscription.swift
//  YoutubeApp
//
//  Created by Admin on 17/01/2024.
//
import Foundation
extension APIManager.Subscription {
    struct QueryString {
        let key = App.Key.apiKey
        let part = "snippet,contentDetails"
        let mine = "true"
        let maxResults = "50"
        
        func getMySubscription() -> String {
            return APIManager.Path.base_domain +
            APIManager.Path.subscriptions +
            "?key=\(key)" +
            "&mine=\(mine)" +
            "&part=\(part)" +
            "&maxResults=\(maxResults)"
        }
        func getSubcriptionExist(channelId: String) -> String{
            return APIManager.Path.base_domain +
            APIManager.Path.subscriptions +
            "?key=\(key)" +
            "&part=\(part)" +
            "&mine=\(mine)" +
            "&forChannelId=\(channelId)"
        }
        func postSubcription() -> String {
            return APIManager.Path.base_domain +
            APIManager.Path.subscriptions +
            "?key=\(key)" +
            "&part=\(part)"
        }
        func deleteSubcription(id: String) -> String {
            return APIManager.Path.base_domain +
            APIManager.Path.subscriptions +
            "?key=\(key)" +
            "&id=\(id)"
        }
    }
    
    static func getAllSubscription(completion: @escaping APICompletion<SubscriptionsResult>) {
        let queryString = QueryString()
        let urlString = queryString.getMySubscription()
        API.shared().request(urlString: urlString, method: "GET") { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let data):
                if let data = data {
                    let json = data.toJSON()
                    guard let items = json["items"] as? [JSON] else {
                        return
                    }
                    var subscriptions: [Subscription] = []
                    
                    let group = DispatchGroup()
                    
                    for item in items {
                        if var subscription = Subscription(json: item) {
                            group.enter()
                            API.shared().downloadImageAsync(with: subscription.avatarChannelUrl) { image in
                                subscription.thumbnailImage = image
                                subscriptions.append(subscription)
                                group.leave()
                            }
                        }
                    }
                    group.notify(queue: .main) {
                        let copyright = "Your copyright information"
                        let nextPageToken = json["nextPageToken"] as? String
                        let subcriptionsResult = SubscriptionsResult(subscriptions: subscriptions, copyright: copyright, update: nextPageToken ?? "")
                        completion(.success(subcriptionsResult))
                    }
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
    static func getSubscriptionExist(channelId: String, completion: @escaping APICompletion<SubscriptionResult>) {
        let queryString = QueryString()
        let urlString = queryString.getSubcriptionExist(channelId: channelId)
        print(urlString)
        API.shared().request(urlString: urlString, method: "GET") { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let data):
                if let data = data {
                    let json = data.toJSON()
                    guard let items = json["items"] as? [JSON] else {
                        return
                    }
                   
                    if items.isEmpty {
                        let subcriptionResult = SubscriptionResult(isSubribe: false)
                        completion(.success(subcriptionResult))
                    }
                    if let item = items.first, let subscription = Subscription(json: item) {
                        let subcriptionResult = SubscriptionResult(subcription: subscription, isSubribe: true)
                        completion(.success(subcriptionResult))
                    }
   
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
    static func postSubcription(body:Data, completion: @escaping APICompletion<Subscription>) {
        let queryString = QueryString()
        let urlString = queryString.postSubcription()
        print("Subcription post: \(urlString)")
        API.shared().requestPost(urlString: urlString, body: body) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                if let data = data {
                    let json = data.toJSON()
                    
                    if let subcription = Subscription(json: json) {
                        completion(.success(subcription))
                        print(subcription)
                    }
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
    static func deleteSubcription(subcriptionId: String, completion: @escaping APICompletion<Bool>) {
        let queryString = QueryString()
        let urlString = queryString.deleteSubcription(id: subcriptionId)
        print("Subcription delete: \(urlString)")
        API.shared().requestDelete(urlString: urlString) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(_):
                completion(.success(true))
            }
        }
    }}
