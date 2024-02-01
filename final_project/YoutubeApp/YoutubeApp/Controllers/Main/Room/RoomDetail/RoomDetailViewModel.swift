//
//  RoomViewController.swift
//  YoutubeApp
//
//  Created by Admin on 26/01/2024.
//

import Foundation
import FirebaseDatabase
class RoomDetailViewModel {
    var videoId: String = ""
    var duration: Float = 0
    var messages = [MessageData]()
    var room: Int = 0
    var countMembers: Int = 0
    var role: String = "user"
    var password: String = ""
    
    let ref = Database.database().reference()
    let user = DataManager.shared().getChannelFromUserDefaults()
    
    func createRoom( completion: @escaping (Int?) -> Void) {
        room = Int.random(in: 1000...9999)
        
        self.ref.child("ActionRoom")
            .child("\(room)")
            .setValue(["play": true,
                       "duration": 0,
                       "videoId": videoId,
                       "password": password])
        { error, _ in
            completion(error == nil ? self.room : nil)
        }
        
    }
    
    func updateRoom(completion: @escaping (Bool, Double) -> Void) {
        if role == "user" {
            let roomRef = ref.child("ActionRoom").child("\(String(describing: room))")
            roomRef.observe(.value) { snapshot, arg  in
                if let roomData = snapshot.value as? [String: Any] {
                    let isPlaying = roomData["play"] as? Bool ?? false
                    let duration = roomData["duration"] as? Double ?? 0.0
                    
                    if isPlaying {
                        completion(true,duration)
                    } else {
                        completion(false,duration)
                    }
                }
            }
        }
    }
    
    func updateUser(completion: @escaping (String, String, String) -> Void) {
        if role == "user" {
            let usersRef = ref.child("Users").child("\(String(describing: room))")
            usersRef.observe(.childAdded) { snapshot in
                if let newUser = snapshot.value as? [String: Any] {
                    let username = newUser["username"] as? String ?? ""
                    let avatar = newUser["avatarChannelUrl"] as? String ?? ""
                    self.countMembers += 1
                    completion(username, avatar, "add")
                }
            }
            usersRef.observe(.childRemoved) { snapshot in
                if let newUser = snapshot.value as? [String: Any] {
                    let username = newUser["username"] as? String ?? ""
                    let avatar = newUser["avatarChannelUrl"] as? String ?? ""
                    self.countMembers -= 1
                    completion(username, avatar, "remove")
                }
            }
        }
    }
    
    func checkPasswordRoom(enteredPassword: String, completion: @escaping (Bool) -> Void) {
        let roomRef = ref.child("ActionRoom").child("\(String(describing: room))")
        
        roomRef.observeSingleEvent(of: .value) { snapshot in
            if let roomData = snapshot.value as? [String: Any] {
                let storedPassword = roomData["password"] as? String ?? ""
                let isPasswordCorrect = enteredPassword == storedPassword
                self.password = storedPassword
                completion(isPasswordCorrect)
                
            } else {
                completion(false)
            }
        }
    }
    
    func createUser( completion: @escaping (Error?) -> Void) {
        self.ref
            .child("Users")
            .child("\(String(describing: room))")
            .child(user?.channelId ?? "")
            .setValue(["username": user?.title, "avatarChannelUrl": user?.avatarChannelUrl])
        { error, _ in
            completion(error)
        }
    }
    
    func deleteUser(completion: @escaping (Error?) -> Void) {
        self.ref.child("Users").child("\(String(describing: room))")
            .child(user?.channelId ?? "")
            .removeValue { error, _ in
                completion(error)
            }
    }
    
    func createMessage(message: String, completion: @escaping (Error?) -> Void) {
        let timestamp = ServerValue.timestamp()
        
        let messageData: [String: Any] = [
            "sendId": user?.channelId ?? "",
            "username": user?.title ?? "",
            "avatarChannelUrl": user?.avatarChannelUrl ?? "",
            "message": message,
            "time": timestamp
        ]
        
        self.ref
            .child("Messages")
            .child("\(String(describing: room))")
            .childByAutoId()
            .setValue(messageData) { error, _ in
                completion(error)
            }
    }
    
    func readMessagesFirstTime(completion: @escaping ([MessageData]?, Error?) -> Void) {
        let messagesRef = ref.child("Messages").child("\(String(describing: room))")
        
        messagesRef.observeSingleEvent(of: .value) { snapshot,arg  in
            guard let messagesData = snapshot.value as? [String: [String: Any]] else {
                completion(nil, nil)
                return
            }
            
            var messagesArray = [MessageData]()
            
            for (_, messageData) in messagesData {
                if let sendId = messageData["sendId"] as? String,
                   let username = messageData["username"] as? String,
                   let avatarChannelUrl = messageData["avatarChannelUrl"] as? String,
                   let time = messageData["time"] as? Int,
                   let messageText = messageData["message"] as? String {
                    
                    let message = MessageData(userId: sendId,
                                              userName: username,
                                              message: messageText,
                                              time: time)
                    
                    messagesArray.append(message)
                }
            }
            self.messages = messagesArray
            completion(messagesArray, nil)
        } withCancel: { error in
            completion(nil, error)
        }
    }
    
    func updateMessage(completion: @escaping (MessageData?, Error?) -> Void) {
        let messagesRef = ref.child("Messages").child("\(String(describing: room))")

        messagesRef.observe(.childAdded) { snapshot, arg in
            guard let messageData = snapshot.value as? [String: Any] else {
                completion(nil, nil)
                return
            }

            if  let sendId = messageData["sendId"] as? String,
                let username = messageData["username"] as? String,
                let avatarChannelUrl = messageData["avatarChannelUrl"] as? String,
                let time = messageData["time"] as? Int,
                let messageText = messageData["message"] as? String {

                API.shared().downloadImage(with: avatarChannelUrl) { image in
                    var imageAvatar: UIImage?

                    if let downloadedImage = image {
                        imageAvatar = downloadedImage
                    } else {
                        // Handle the case where image download fails, set a default image, etc.
                        imageAvatar = UIImage()
                    }

                    let message = MessageData(userId: sendId,
                                              userName: username,
                                              message: messageText,
                                              time: time,
                                              avatarImage: imageAvatar)

                    self.messages.append(message)
                    self.messages.sort { $0.time < $1.time }
                    completion(message, nil)
                }
            }
        }
    }

    
    
}


