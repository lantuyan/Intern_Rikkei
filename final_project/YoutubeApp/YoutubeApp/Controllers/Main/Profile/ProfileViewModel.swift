//
//  ProfileViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import Foundation
import RealmSwift
class ProfileViewModel {
    var dataVideos: [DataVideo] = []
    var subscriptions: [Subscription] = []
    
    func getAllVideosFromRealm() {
        do {
            let realm = try Realm()
            let allVideos = realm.objects(DataVideo.self).sorted(byKeyPath: "lastUpdated", ascending: false)
            self.dataVideos = Array(allVideos)
            print("Fetched \(self.dataVideos.count) videos sorted from newest to oldest.")
        } catch {
            print("Error fetching all videos from Realm: \(error)")
        }
    }

    func getAllSubscription(completion: @escaping Completion) {
        APIManager.Subscription.getAllSubscription{ result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                
            case .success(let videoResult):
                self.subscriptions.append(contentsOf: videoResult.subscriptions)
                
                completion(true,"")
            }
        }
    }
}
