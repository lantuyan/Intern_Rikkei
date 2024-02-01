//
//  Networking.swift
//  YoutubeApp
//
//  Created by Admin on 05/01/2024.
//

import Foundation
import UIKit
class Networking {
    private static var sharedNetworking: Networking = {
        let networking = Networking()
        return networking
    }()
    
    class func shared() -> Networking {
        return sharedNetworking
    }
    
    private init() {}
    
    // request
    func request(with urlString: String, completion: @escaping(Data?, APIError?) -> Void ) {
        guard let url = URL(string: urlString) else {
            let error = APIError.error("URL Error")
            completion(nil,error)
            return
        }
        
        // tạo cấu hình cho session
        let config = URLSessionConfiguration.ephemeral // Các phiên ephemeral không lưu trữ cache, cookie, thông tin đăng nhập vào ổ đĩa.
        config.waitsForConnectivity = true
            
        // tạo đối tượng URLSession
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("API fail")
                } else {
                    print("API success")
                    
                    if let data = data {
                        completion(data,nil)
                    } else {
                        completion(nil, APIError.error("Data format error"))
                    }
                }
            }
        }
        task.resume()
    }
    
    
    
}
