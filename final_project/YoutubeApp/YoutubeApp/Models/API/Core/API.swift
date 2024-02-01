//
//  API.swift
//  YoutubeApp
//
//  Created by Admin on 05/01/2024.
//

import Foundation

typealias APICompletion<T> = (Result<T, APIError>) -> Void

enum APIError: Error {
    case error(String)
    case errorURL
    
    var localizedDescription: String {
        switch self {
        case .error(let string):
            return string
        case .errorURL:
            return "URL String is error."
        }
    }
}

enum APIResult {
    case success(Data?)
    case failure(APIError)
}

struct API {
    private static var shareAPI: API = {
        let shareAPI = API()
        return shareAPI
    }()
    
    static func shared() -> API {
        return shareAPI
    }
    
    private init() {
        
    }
}
