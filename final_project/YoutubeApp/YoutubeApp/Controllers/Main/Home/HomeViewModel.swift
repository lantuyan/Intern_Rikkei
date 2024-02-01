//
//  HomeViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 04/01/2024.
//

import Foundation

class HomeViewModel {
    var nextPageToken: String = ""
    var videos: [Video] = []
    var categoryVideos: [String: [Video]] = [:]
    var categories: [Category] = []
    var channels: [Channel] = []
    var newDataVideos: [Video] = []
    
    func loadAPI(completion: @escaping Completion) {
        APIManager.Video.getListVideoPopular { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                
            case .success(let videoResult):
                self.videos.append(contentsOf: videoResult.videos)
                self.nextPageToken = videoResult.update
                
                completion(true,"")
            }
        }
    }
    
    func loadMoreAPI(categoryId: String ,completion: @escaping Completion) {
        APIManager.Video.getListVideoByCategoryId(nextPageToken: nextPageToken, categoryId: categoryId) { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                
            case .success(let videoResult):
                self.videos.append(contentsOf: videoResult.videos)
                self.nextPageToken = videoResult.update
                self.newDataVideos = videoResult.videos
                completion(true,"")
            }
        }
    }
    
    func loadChannel(index: Int, channelId: String) {
        APIManager.Channel.getChannelInfo(channelId: channelId) { result in
            switch result {
            case .failure(_): break
                
            case .success(let Result):
                self.videos[index].channel = Result.channel
            }
        }
    }
    
    func loadCategory(completion: @escaping Completion) {
        APIManager.Category.getListCategory { result in
            switch result {
            case .failure(let error):
                
                completion(false, error.localizedDescription)
            case .success(let categoryResult):
                self.categories.append(Category(categoryId: "0", title: "Tất cả", assignable: true))
                self.categories.append(contentsOf: categoryResult.categories)
                completion(true, "")
            }
        }
    }
    
    func loadAPIByCategory(categoryID: String, completion: @escaping Completion ) {
        self.videos.removeAll()
        print(videos)
        if let cachedVideos = categoryVideos[categoryID], !cachedVideos.isEmpty {
            // If data is already loaded for this category, use the cached data
            self.videos = cachedVideos
            completion(true, "")
        } else {
            // Otherwise, make an API call to fetch data for the category
            APIManager.Video.getListVideoByCategoryId(categoryId: categoryID) { result in
                switch result {
                case .failure(let error):
                    completion(false, error.localizedDescription)
                case .success(let videoResult):
                    self.videos = videoResult.videos
                    self.nextPageToken = videoResult.update
                    self.categoryVideos[categoryID] = videoResult.videos // Cache the data
                    completion(true, "")
                }
            }
        }
    }
}
