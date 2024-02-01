//
//  RoomViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 29/01/2024.
//

import Foundation
import FirebaseDatabase
class RoomViewModel {
    var allRooms: [RoomData] = []
    
    func readAllRooms(completion: @escaping (Bool) -> Void) {
        let actionRoomsRef = Database.database().reference().child("ActionRoom")
        actionRoomsRef.observe(.value) { [weak self] snapshot in
            guard let self = self else { return }
            
            self.allRooms.removeAll()
            var hasRooms = false
            
            if let roomData = snapshot.value as? [String: [String: Any]] {
                for (roomId, roomDetails) in roomData {
                    let play = roomDetails["play"] as? Bool ?? false
                    let duration = roomDetails["duration"] as? Double ?? 0.0
                    let videoId = roomDetails["videoId"] as? String ?? ""
                    
                    let room = RoomData(roomId: Int(roomId) ?? 0, play: play, duration: duration, videoId: videoId)
                    self.allRooms.append(room)
                    hasRooms = true
                }
            }
            
            completion(hasRooms)
        }
    }

}
