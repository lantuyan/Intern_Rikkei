//
//  SearchViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 11/01/2024.
//

import Foundation
class SearchViewModel {
    
    var videos: [VideoForSearch] = []
    var categories: [Category] = []
    var nextPageToken: String = ""
    
    func loadAPIByQuery(query: String, completion: @escaping Completion) {
        videos.removeAll()
        APIManager.Video.getListVideoByQuery(query: query) { result in
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
    
    func loadMoreAPI(query: String ,completion: @escaping Completion) {
        APIManager.Video.getListVideoByQuery(pageToken: nextPageToken, query: query) { result in
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
    
        
}
