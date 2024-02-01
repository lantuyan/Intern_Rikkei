//
//  API.Category.swift
//  YoutubeApp
//
//  Created by Admin on 09/01/2024.
//

import Foundation
extension APIManager.Category {
    struct QueryString {
        //videoCategories?hl=vi&part=snippet&regionCode=VN&key=AIzaSyBKgj7qB4YkfBRc2Va3ksVA8003MVtHbyQ
        let key = App.Key.apiKey
        let regionCode = "VN"
        let hl = "vi"
        let part = "snippet"
        
        func listCategory() -> String {
            return APIManager.Path.base_domain +
            APIManager.Path.video_categories +
            "?key=\(key)" +
            "&part=\(part)" +
            "&regionCode=\(regionCode)" +
            "&hl=\(hl)"
            
        }
    }
    
    struct CategoryResult {
        var categories: [Category]
        var copyright: String
        var update: String
    }
}

extension APIManager.Category {
    
    static func getListCategory(completion: @escaping APICompletion<CategoryResult>) {
        let queryString = QueryString()
        let urlString = queryString.listCategory()
        //        print(urlString)
        
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
                    var categories: [Category] = []
                    
                    for item in results {
                        if let category = Category(json: item), category.assignable == true {
                            categories.append(category)
                        }
                    }
                    
                    let copyright = "Your copyright information"
                    let updated = "Your update information"
                    print(categories)
                    let videoResult = CategoryResult(categories: categories, copyright: copyright, update: updated)
                    completion(.success(videoResult))
                } else {
                    completion(.failure(.error("Data is not formatted")))
                }
            }
        }
    }
    
}
