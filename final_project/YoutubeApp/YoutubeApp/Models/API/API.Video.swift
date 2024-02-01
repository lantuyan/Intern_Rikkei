//
//  API.Video.swift
//  YoutubeApp
//
//  Created by Admin on 05/01/2024.
//

import Foundation
extension APIManager.Video {
    struct QueryString {
        //https://youtube.googleapis.com/youtube/v3/videos?key=AIzaSyBKgj7qB4YkfBRc2Va3ksVA8003MVtHbyQ&maxResults=50&part=snippet,contentDetails,id,statistics&regionCode=VN&chart=mostPopular&videoCategoryId=1
        let key = App.Key.apiKey
        let regionCode = "VN"
        let chart = "mostPopular"
        let part = "snippet,contentDetails,id,statistics"
        
        private func generateBaseURL(maxResults: String, additionalParameters: String) -> String {
            return APIManager.Path.base_domain +
            APIManager.Path.videos +
            "?key=\(key)" +
            "&maxResults=\(maxResults)" +
            "&part=\(part)" +
            "&regionCode=\(regionCode)" +
            additionalParameters
        }
        
        func listDataPopular(maxResults: String, nextPageToken: String?) -> String {
            let additionalParameters = "&chart=\(chart)" + "&pageToken=\(nextPageToken ?? "")"
            return generateBaseURL(maxResults: maxResults, additionalParameters: additionalParameters)
        }
        
        func listDataByCategoryID(maxResults: String, categoryId: String, nextPageToken: String?) -> String {
            let additionalParameters = "&chart=\(chart)" + "&videoCategoryId=\(categoryId)" + "&pageToken=\(nextPageToken ?? "")"
            return generateBaseURL(maxResults: maxResults, additionalParameters: additionalParameters)
        }
        
        func listDataLike(maxResults: String, nextPageToken: String?) -> String {
            let additionalParameters = "&myRating=like" + "&pageToken=\(nextPageToken ?? "")"
            return generateBaseURL(maxResults: maxResults, additionalParameters: additionalParameters)
        }
        
        func listDataDisLike(maxResults: String, nextPageToken: String?) -> String {
            let additionalParameters = "&myRating=dislike" + "&pageToken=\(nextPageToken ?? "")"
            return generateBaseURL(maxResults: maxResults, additionalParameters: additionalParameters)
        }
        
        func listDataByQuery(maxResults: String, query: String, pageToken: String) -> String {
            let additionalParameters =
            "&part=snippet,id" +
            "&q=\(query)"
            
            return APIManager.Path.base_domain +
            APIManager.Path.search +
            "?key=\(key)" +
            "&maxResults=\(maxResults)" +
            "&regionCode=\(regionCode)" +
            "&pageToken=\(pageToken)" +
            additionalParameters
        }
        
        func dataVideoById(id: String) -> String{
            return  APIManager.Path.base_domain +
            APIManager.Path.videos +
            "?key=\(key)" +
            "&part=\(part)" +
            "&id=\(id)"
        }
        
        func getRatingVideoById(id: String) -> String {
            return  APIManager.Path.base_domain +
            APIManager.Path.videos +
            "/getRating" +
            "?key=\(key)" +
            "&id=\(id)"
            
        }
        
        func postRatingVideoByid(id: String, rating: String) -> String {
            APIManager.Path.base_domain +
            APIManager.Path.videos +
            "/rate" +
            "?key=\(key)" +
            "&id=\(id)" +
            "&rating=\(rating)"
            
        }
        
    }
    
    
}

extension APIManager.Video {
    static func getVideoById(id: String, completion: @escaping APICompletion<Video>) {
        let urlString = QueryString().dataVideoById(id: id)
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
                    
                    if let firstItem = items.first, let video = Video(json: firstItem) {
                        APIManager.Channel.getChannelInfo(channelId: video.channelId) { result in
                            switch result {
                            case .failure(let error):
                                print("Error getting channel info: \(error)")
                                completion(.failure(error))
                                
                            case .success(let channel):
                                var videoWithChannel = video
                                videoWithChannel.channel = channel.channel
                                
                                API.shared().downloadImage(with: videoWithChannel.channel?.avatarChannelUrl ?? "") { (image) in
                                    if let image = image {
                                        videoWithChannel.channelImage = image
                                        print("Download channel image success")
                                    } else {
                                        print("Download Channel image fail")
                                    }
                                }
                                
                                API.shared().downloadImage(with: videoWithChannel.thumbnailUrl) { (image) in
                                    if let image = image {
                                        videoWithChannel.thumbnailImage = image
                                        print("Download Thumbnail image success")
                                    } else {
                                        print("Download Thumbnail image fail")
                                    }
                                    completion(.success(videoWithChannel))
                                }
                            }
                        }
                    } else {
                        completion(.failure(.error("Data is not formatted")))
                    }
                }
            }
        }
    }
    
    static func getListVideoPopular(maxResults: Int = 10, nextPageToken: String = "", completion: @escaping APICompletion<VideoResult>) {
        let urlString = QueryString().listDataPopular(maxResults: String(maxResults), nextPageToken: nextPageToken)
        print(urlString)
        getListVideo(with: urlString, completion: completion)
    }
    
    static func getListVideoByCategoryId(maxResults: Int = 10, nextPageToken: String = "", categoryId: String, completion: @escaping APICompletion<VideoResult>) {
        let urlString = QueryString().listDataByCategoryID(maxResults: String(maxResults), categoryId: categoryId, nextPageToken: nextPageToken)
        print(urlString)
        getListVideo(with: urlString, completion: completion)
    }
    
    static func getListLikeVideo(maxResults: Int = 10, nextPageToken: String = "", completion: @escaping APICompletion<VideoResult>) {
        let urlString = QueryString().listDataLike(maxResults: String(maxResults), nextPageToken: nextPageToken)
        print(urlString)
        getListVideoByRating(with: urlString, completion: completion)
    }
    
    static func getListDisLikeVideo(maxResults: Int = 10, nextPageToken: String = "", completion: @escaping APICompletion<VideoResult>) {
        let urlString = QueryString().listDataDisLike(maxResults: String(maxResults), nextPageToken: nextPageToken)
        print(urlString)
        getListVideoByRating(with: urlString, completion: completion)
    }
    
    
    static func getListVideo(with urlString: String, completion: @escaping APICompletion<VideoResult>) {
        API.shared().request(urlString: urlString) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.error("Data is not formatted")))
                    return
                }
                let json = data.toJSON()
                guard let results = json["items"] as? [JSON] else {
                    return
                }
                if results.count < 5 {
                    completion(.failure(APIError.error("List doesn't have enough items")))
                    return
                }
                var videos: [Video] = []
                let dispatchGroup = DispatchGroup()
                for item in results {
                    if var video = Video(json: item) {
                        dispatchGroup.enter()
                        
                        APIManager.Channel.getChannelInfo(channelId: video.channelId) { channelResult in
                            API.shared().downloadImage(with: video.thumbnailUrl) { (thumbnailImage) in
                                if let thumbnailImage = thumbnailImage {
                                    video.thumbnailImage = thumbnailImage
                                }
                                if case .success(let channelResult) = channelResult {
                                    API.shared().downloadImage(with: channelResult.channel.avatarChannelUrl) { (channelImage) in
                                        if let channelImage = channelImage {
                                            video.channelImage = channelImage
                                            video.channel = channelResult.channel
                                        }
                                        videos.append(video)
                                        dispatchGroup.leave()
                                    }
                                } else {
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
                // Notify on the main queue when all tasks in the dispatch group are done
                dispatchGroup.notify(queue: .main) {
                    let copyright = "Your copyright information"
                    let updated = json["nextPageToken"] as? String
                    let videoResult = VideoResult(videos: videos, copyright: copyright, update: updated ?? "none")
                    completion(.success(videoResult))
                }
            }
        }
    }
    
    static func getListVideoByRating(with urlString: String, completion: @escaping APICompletion<VideoResult>) {
        API.shared().request(urlString: urlString, method: "GET") { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let data = data else {
                    completion(.failure(.error("Data is not formatted")))
                    return
                }
                let json = data.toJSON()
                guard let results = json["items"] as? [JSON] else {
                    completion(.failure(APIError.error("List doesn't have enough items")))
                    return
                }
                
                var videos: [Video] = []
                let dispatchGroup = DispatchGroup()
                for item in results {
                    if var video = Video(json: item) {
                        dispatchGroup.enter()
                        
                        APIManager.Channel.getChannelInfo(channelId: video.channelId) { channelResult in
                            API.shared().downloadImage(with: video.thumbnailUrl) { (thumbnailImage) in
                                if let thumbnailImage = thumbnailImage {
                                    video.thumbnailImage = thumbnailImage
                                }
                                if case .success(let channelResult) = channelResult {
                                    API.shared().downloadImage(with: channelResult.channel.avatarChannelUrl) { (channelImage) in
                                        if let channelImage = channelImage {
                                            video.channelImage = channelImage
                                            video.channel = channelResult.channel
                                        }
                                        videos.append(video)
                                        dispatchGroup.leave()
                                    }
                                } else {
                                    dispatchGroup.leave()
                                }
                            }
                        }
                    }
                }
                // Notify on the main queue when all tasks in the dispatch group are done
                dispatchGroup.notify(queue: .main) {
                    let copyright = "Your copyright information"
                    let updated = json["nextPageToken"] as? String
                    let videoResult = VideoResult(videos: videos, copyright: copyright, update: updated ?? "none")
                    completion(.success(videoResult))
                }
            }
        }
    }
    
    static func getListVideoByQuery(pageToken: String = "", maxResults: Int = 10,query: String, completion: @escaping APICompletion<VideoResultForSearch>) {
        let queryString = QueryString()
        let urlString = queryString.listDataByQuery(maxResults: String(maxResults), query: query, pageToken: pageToken)
        print(urlString)
        
        API.shared().request(urlString: urlString) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let data):
                if let data = data {
                    let json = data.toJSON()
                    guard let results = json["items"] as? [JSON] else {
                        return
                    }
                    var videos: [VideoForSearch] = []
                    
                    let dispatchGroup = DispatchGroup()   
                    for item in results {
                        if var video = VideoForSearch(json: item) {
                            
                            dispatchGroup.enter()
                            
                            APIManager.Channel.getChannelInfo(channelId: video.channelId) { channelResult in
                                API.shared().downloadImage(with: video.thumbnailUrl) { (thumbnailImage) in
                                    if let thumbnailImage = thumbnailImage {
                                        video.thumbnailImage = thumbnailImage
                                    }
                                    if case .success(let channelResult) = channelResult {
                                        API.shared().downloadImage(with: channelResult.channel.avatarChannelUrl) { (channelImage) in
                                            if let channelImage = channelImage {
                                                video.channelImage = channelImage
                                                video.channel = channelResult.channel
                                            }
                                            videos.append(video)
                                            dispatchGroup.leave()
                                        }
                                    } else {
                                        dispatchGroup.leave()
                                    }
                                }
                                
//                                defer {
//                                    dispatchGroup.leave()
//                                }
//                                switch result {
//                                case .failure(_): break
//                                    
//                                case .success(let Result):
//                                    video.channel = Result.channel
//                                    videos.append(video)
//                                }
                            }
                        }
                        
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        let copyright = "Your copyright information"
                        let updated = json["nextPageToken"] as? String
                        let videoResult = VideoResultForSearch(videos: videos, copyright: copyright, update: updated ?? "")
                        completion(.success(videoResult))
                    }
                    
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
}

extension APIManager.Video {
    static func getRatingById(VideoId: String, completion: @escaping APICompletion<RatingResult>) {
        let queryString = QueryString()
        let urlString = queryString.getRatingVideoById(id: VideoId)
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
                    var ratings: [Rating] = []
                    
                    for item in items {
                        if let rating = Rating(json: item) {
                            ratings.append(rating)
                        }
                    }
                    let copyright = "Your copyright information"
                    let ratingResult = RatingResult(ratings: ratings, copyright: copyright)
                    completion(.success(ratingResult))
                    
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
    static func postRatingById(VideoId: String, rating: String, completion: @escaping APICompletion<String>) {
        let queryString = QueryString()
        let urlString = queryString.postRatingVideoByid(id: VideoId, rating: rating)
        print("Post Rating: \(urlString)")
        API.shared().requestPost(urlString: urlString, body: nil) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .success(let data):
                if let data = data {
                    completion(.success("success"))
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
}



