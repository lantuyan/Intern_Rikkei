//
//  ListLikeViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 17/01/2024.
//

import Foundation
import RealmSwift
class ListSaveViewModel {
    var dataVideos: [DataVideo] = []
    
    func getAllVideosFromRealm() {
        do {
            let realm = try Realm()
            let allVideos = realm.objects(DataVideo.self).filter("isSaved == %@", true)
            self.dataVideos = Array(allVideos)
            self.dataVideos.reverse()
        } catch {
            print("Error fetching all videos from Realm: \(error)")
        }
    }
}
