//
//  API.Comment.swift
//  YoutubeApp
//
//  Created by Admin on 13/01/2024.
//

import Foundation
extension APIManager.Comment {
    struct QueryString {
        let key = App.Key.apiKey
        let regionCode = "VN"
        let order = "relevance"
        let part = "id,snippet,replies"
        
        func getCommentsUrl(maxResults:String, videoId: String) -> String {
            return APIManager.Path.base_domain +
            APIManager.Path.commentThreads +
            "?key=\(key)" +
            "&videoId=\(videoId)" +
            "&order=\(order)" +
            "&part=\(part)" +
            "&maxResults=\(maxResults)"
            
        }
        
        func postCommentUrl() -> String {
            return APIManager.Path.base_domain +
            APIManager.Path.commentThreads +
            "?key=\(key)" +
            "&part=\(part)"
            
        }
    }
    
    static func getComments(maxResults: Int = 50, videoId: String, completion: @escaping APICompletion<CommentsResult>) {
        let queryString = QueryString()
        let urlString = queryString.getCommentsUrl(maxResults: String(maxResults), videoId: videoId)
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
                    
                    var comments: [Comment] = []
                    
                    for item in items {
                        if let comment = Comment(json: item) {
                            comments.append(comment)
                        }
                    }
                    
                    let copyright = "Your copyright information"
                    let nextPageToken = json["nextPageToken"] as? String
                    let commentResult = CommentsResult(comments: comments, copyright: copyright, nextPageToken: nextPageToken ?? "")
                    completion(.success(commentResult))
                    
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
        
    }
    
    static func postComment( body:Data, completion: @escaping APICompletion<Comment>) {
        let queryString = QueryString()
        let urlString = queryString.postCommentUrl()
        print("Post comment: \(urlString)")
        API.shared().requestPost(urlString: urlString, body: body) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let data):
                if let data = data {
                    let json = data.toJSON()
                    
                    if let comment = Comment(json: json) {
                        completion(.success(comment))
                        print(comment)
                    }
       
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
}
