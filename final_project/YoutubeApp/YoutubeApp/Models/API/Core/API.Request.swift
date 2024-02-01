//
//  API.Request.swift
//  YoutubeApp
//
//  Created by Admin on 17/01/2024.
//

import Foundation
import Alamofire
import GoogleSignIn
extension API {
    func request(urlString: String, completion: @escaping (APIResult) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if (400...499).contains(httpResponse.statusCode) {
                        // Handle 4xx errors
                        completion(.failure(.error("\(httpResponse.statusCode) Client Error")))
                    } else if httpResponse.statusCode == 404 {
                        completion(.failure(.error("404 Not Found")))
                    } else if let error = error {
                        completion(.failure(.error(error.localizedDescription)))
                    } else {
                        print("API success")
                        if let data = data {
                            completion(.success(data))
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    
    func request(urlString: String, method: String = "GET", completion: @escaping (APIResult) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        // Assuming you have obtained the access token from GoogleSignIn
        if let googleAccessToken = GIDSignIn.sharedInstance()?.currentUser?.authentication?.accessToken {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method
            
            // Add the Google access token to the headers
            urlRequest.addValue("Bearer \(googleAccessToken)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let config = URLSessionConfiguration.ephemeral
            config.waitsForConnectivity = true
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(.error(error.localizedDescription)))
                    } else {
                        print("API success")
                        if let data = data {
                            completion(.success(data))
                        }
                    }
                }
            }
            task.resume()
        } else {
            // Handle the case where the Google access token is not available
            completion(.failure(.error("Google access token not available")))
        }
    }
    
    func requestPost(urlString: String, body: Data?, completion: @escaping (APIResult) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.error("Invalid URL")))
            return
        }
        
        // Assuming you have obtained the access token from GoogleSignIn
        if let googleAccessToken = GIDSignIn.sharedInstance()?.currentUser?.authentication?.accessToken {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            // Add the Google access token and content type to the headers
            urlRequest.addValue("Bearer \(googleAccessToken)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Attach the body to the request
            urlRequest.httpBody = body
            
            let config = URLSessionConfiguration.ephemeral
            config.waitsForConnectivity = true
            let session = URLSession(configuration: config)
            
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(.error(error.localizedDescription)))
                    } else if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.error("No data received")))
                    }
                }
            }
            task.resume()
        } else {
            // Handle the case where the Google access token is not available
            completion(.failure(.error("Google access token not available")))
        }
    }
    
    func requestDelete(urlString: String, completion: @escaping (APIResult) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.error("Invalid URL")))
            return
        }
        // Assuming you have obtained the access token from GoogleSignIn
        if let googleAccessToken = GIDSignIn.sharedInstance()?.currentUser?.authentication?.accessToken {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            // Add the Google access token and content type to the headers
            urlRequest.addValue("Bearer \(googleAccessToken)", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let config = URLSessionConfiguration.ephemeral
            config.waitsForConnectivity = true
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(.error(error.localizedDescription)))
                    } else if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.error("No data received")))
                    }
                }
            }
            task.resume()
        } else {
            // Handle the case where the Google access token is not available
            completion(.failure(.error("Google access token not available")))
        }
    }
}

extension API {
    func requestAF(urlString: String, completion: @escaping (APIResult) -> Void) {
        AF.request(urlString)
            .validate()  // Validates the response status code and content type
            .responseData { response in
                DispatchQueue.main.async {
                    switch response.result {
                    case .success(let data):
                        print("API success")
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(.error(error.localizedDescription)))
                    }
                }
            }
    }
    
    func requestAF(urlString: String, method: HTTPMethod = .get, completion: @escaping (Result<Data, AFError>) -> Void) {
        guard let url = URL(string: urlString),
              let googleAccessToken = GIDSignIn.sharedInstance()?.currentUser?.authentication?.accessToken else {
            completion(.failure(AFError.invalidURL(url: urlString)))
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer \(googleAccessToken)", "Content-Type": "application/json"]
        
        AF.request(url, method: method, headers: headers)
            .validate()
            .responseData { response in
                completion(response.result)
            }
    }
    
    func requestPost(urlString: String, parameters: [String: Any], completion: @escaping (Result<Data, Error>) -> Void) {
        // Assuming you have the Google access token available
        guard let url = URL(string: urlString),
              let googleAccessToken = GIDSignIn.sharedInstance()?.currentUser?.authentication?.accessToken else {
            completion(.failure(AFError.invalidURL(url: urlString)))
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(googleAccessToken)",
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
