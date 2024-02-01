//
//  API+Extension.swift
//  YoutubeApp
//
//  Created by Admin on 05/01/2024.
//

import Foundation
import UIKit

extension API {
    
    //download image
    func downloadImage(with urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            _ = APIError.error("URL lỗi")
            completion(nil)
            return
        }
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: url) { (data, response, error )in
            DispatchQueue.main.async {
                if error != nil {
                    completion(nil)
                } else {
                    if let data = data {
                        let image = UIImage(data: data)
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func downloadImageAsync(with urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                completion(UIImage(data: data))
            } else {
                completion(nil)
            }
        }.resume()
    }


}
