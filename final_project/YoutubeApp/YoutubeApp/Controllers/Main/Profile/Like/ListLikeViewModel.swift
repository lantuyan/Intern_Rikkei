//
//  ListLikeViewModel.swift
//  YoutubeApp
//
//  Created by Admin on 25/01/2024.
//

import Foundation
class ListLikeViewModel {
    var dataVideos: [Video] = []
    var nextPageToken: String = ""
    
    func loadAPI(completion: @escaping Completion) {
        APIManager.Video.getListLikeVideo { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                
            case .success(let videoResult):
                self.dataVideos.append(contentsOf: videoResult.videos)
                self.nextPageToken = videoResult.update
                
                completion(true,"")
            }
        }
    }
    
    func loadMoreAPI(completion: @escaping Completion) {
        APIManager.Video.getListLikeVideo(nextPageToken: nextPageToken) { result in
            switch result {
            case .failure(let error):
                completion(false, error.localizedDescription)
                
            case .success(let videoResult):
                self.dataVideos.append(contentsOf: videoResult.videos)
                self.nextPageToken = videoResult.update
                completion(true,"")
            }
        }
    }
}
