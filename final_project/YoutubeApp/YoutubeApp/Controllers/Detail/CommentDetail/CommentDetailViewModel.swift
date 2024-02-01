//
//  CommentDetailViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 15/01/2024.
//

import Foundation
class CommentDetailViewModel {
    
    var comments: [Comment] = []
    var videoId: String = ""
    var nextPageCommentsToken = ""
    var postComment: Comment?
    
    func postCommentAPI(textOriginal: String,completion: @escaping Completion) {
        let json: [String: Any] = [
            "snippet": [
                "videoId": "\(videoId)",
                "topLevelComment": [
                    "snippet": [
                        "textOriginal": "\(textOriginal)"
                    ]
                ]
            ]
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            APIManager.Comment.postComment(body: jsonData) { result in
                switch result {
                case .failure(let error):
                    completion(false, error.localizedDescription)
                    
                case .success(let commentResult):
                    self.postComment = commentResult
                    self.comments.insert(commentResult, at: 0)
                    completion(true,"")
                }
            }
        } catch  {
            print("Error serializing JSON: \(error)")
        }
    }
}
