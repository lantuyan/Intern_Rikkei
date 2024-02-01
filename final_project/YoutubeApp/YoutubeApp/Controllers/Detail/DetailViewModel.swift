//
//  HomeDetailViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 09/01/2024.
//

import Foundation
import RealmSwift
class DetailViewModel {
    var nextPageToken: String = ""
    var id: String = ""
    var video: Video?
    var subcription: Subscription?
    var comments: [Comment] = []
    var rating: String = ""
    var isSubcribe: Bool = false
    var nextPageCommentsToken = ""
    var postComment: Comment?
}

extension DetailViewModel {
    func loadVideoAPI(completion: @escaping Completion) {
        APIManager.Video.getVideoById(id: id) { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                print("API video error", error.localizedDescription)
            case .success(let result):
                self.video = result
                completion(true,"")
            }
        }
    }
    
    func loadCommentAPI(completion: @escaping Completion) {
        APIManager.Comment.getComments(videoId: id) { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                
            case .success(let commentResult):
                self.comments.append(contentsOf: commentResult.comments)
                self.nextPageCommentsToken = commentResult.nextPageToken
                completion(true,"")
            }
        }
    }
    
    func loadRatingVideoAPI(completion: @escaping Completion) {
        APIManager.Video.getRatingById(VideoId: id) { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                
            case .success(let commentResult):
                self.rating = commentResult.ratings.first?.rating ?? "none"
                completion(true,"")
            }
        }
    }
    
    func loadSubscriptionStatus(completion: @escaping Completion) {
        APIManager.Subscription.getSubscriptionExist(channelId: video?.channel?.channelId ?? "") { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                
            case .success(let subcriptionResult):
                if subcriptionResult.isSubribe {
                    self.subcription = subcriptionResult.subcription
                    self.isSubcribe = true
                } else {
                    self.isSubcribe = false
                }
                completion(true,"")
            }
        }
    }
    
    func postSubcriptionAPI(channelId: String,completion: @escaping Completion) {
        let json: [String: Any] = [
            "snippet": [
                "resourceId": [
                    "kind": "youtube#channel",
                    "channelId": "\(channelId)"
                ]
            ]
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            APIManager.Subscription.postSubcription(body: jsonData) { result in
                switch result {
                case .failure(let error):
                    completion(false, error.localizedDescription)
                case .success(let subcriptionResult):
                    self.subcription = subcriptionResult
                    self.isSubcribe = true
                    completion(true,"")
                }
            }
        } catch  {
            print("Error serializing JSON: \(error)")
        }
    }
    
    func deleteSubcriptionAPI(subcriptionId: String, completion: @escaping Completion) {
        APIManager.Subscription.deleteSubcription(subcriptionId: subcriptionId) { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
            case .success(_):
                self.isSubcribe = false
                completion(true,"")
            }
        }
    }
    
    func sendRatingVideoAPI(rating: String, completion: @escaping Completion){
        APIManager.Video.postRatingById(VideoId: id, rating: rating) { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
            case .success(_):
                self.rating = rating
                completion(true,"")
            }
        }
    }
}

extension DetailViewModel {
    func addVideo() {
        guard let video = self.video else {
            print("Error: Video is nil")
            return
        }
        do {
            let realm = try Realm()
            if let existingVideo = realm.objects(DataVideo.self).filter("videoId == %@", video.videoId).first {
                try realm.write {
                    existingVideo.lastUpdated = Date()
                    print("Existing video moved to last.")
                }
            } else {
                let dataVideo = DataVideo(video: video)
                try realm.write {
                    realm.add(dataVideo)
                    print("New video added.")
                }
            }
        } catch {
            print("Error handling object in Realm: \(error)")
        }
    }
    
    func saveCheck(completion: @escaping (Bool) -> Void) {
        guard let video = self.video else {
            print("Error: Video is nil")
            completion(false)
            return
        }
        do {
            let realm = try Realm()
            let existingVideo = realm.objects(DataVideo.self).filter("videoId == %@", video.videoId).first
            
            if let existingVideo = existingVideo {
                if existingVideo.isSaved {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        } catch {
            print("Error checking like status: \(error)")
            completion(false)
        }
    }
    
    func saveVideo(completion: @escaping (Bool) -> Void) {
        guard let video = self.video else {
            print("Error: Video is nil")
            completion(false)
            return
        }
        do {
            let realm = try Realm()
            let existingVideo = realm.objects(DataVideo.self).filter("videoId == %@", video.videoId).first
            
            if let existingVideo = existingVideo {
                if existingVideo.isSaved {
                    try realm.write {
                        existingVideo.isSaved = false
                        completion(true)
                    }
                } else {
                    try realm.write {
                        existingVideo.isSaved = true
                        completion(true)
                    }
                }
            }
        } catch {
            print("Error checking like status: \(error)")
            completion(false)
        }
    }
    
    func fetchData() {
        do {
            let realm = try Realm()
            let videos = realm.objects(DataVideo.self)
            
            for video in videos {
                print("Video ID: \(video.videoId)")
                print("Title: \(video.title)")
                print("is Like: \(video.isSaved)")
                print("------")
            }
        } catch {
            print("Error fetching data from Realm: \(error)")
        }
    }
    
    func deleteAllData() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
            }
            print("All data deleted from Realm.")
        } catch {
            print("Error deleting all data from Realm: \(error)")
        }
    }
    
    func deleteVideo(withVideoId videoId: String) {
        do {
            let realm = try Realm()
            if let videoToDelete = realm.objects(DataVideo.self).filter("videoId == %@", videoId).first {
                try realm.write {
                    realm.delete(videoToDelete)
                    print("Video with videoId \(videoId) deleted from Realm.")
                }
            } else {
                print("Video with videoId \(videoId) not found in Realm.")
            }
        } catch {
            print("Error deleting video with videoId \(videoId) from Realm: \(error)")
        }
    }
    
}
