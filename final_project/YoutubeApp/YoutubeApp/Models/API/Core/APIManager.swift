//
//  APIManager.swift
//  YoutubeApp
//
//  Created by Admin on 05/01/2024.
//

import Foundation
struct APIManager {
    // https://youtube.googleapis.com/youtube/v3/videos?key=AIzaSyBKgj7qB4YkfBRc2Va3ksVA8003MVtHbyQ&maxResults=50&part=snippet,contentDetails,id,statistics&regionCode=VN&chart=mostPopular&videoCategoryId=1
    struct Path {
        static let base_domain = "https://youtube.googleapis.com/youtube/v3"
        static let videos = "/videos"
        static let video_categories = "/videoCategories"
        static let channel = "/channels"
        static let search = "/search"
        static let commentThreads = "/commentThreads"
        static let subscriptions = "/subscriptions"
    }
    
    struct Video {
        
    }
    
    struct Channel {
        
    }
    
    struct Category {
        
    }
    
    struct Comment {
        
    }
    
    struct Subscription {
        
    }
    
    struct Downloader {
        
    }
}
