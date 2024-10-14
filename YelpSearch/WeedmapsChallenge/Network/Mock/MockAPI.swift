//
//  MockAPI.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import UIKit

class MockAPI: APIService {
    
    private let decoder = JSONDecoder()
    private let cache = NSCache<NSString, NSData>()
    
    func fetchData<T: Decodable>(
        payloadType: T.Type,
        from endpoint: APIEndpoint,
        method: Method = .GET
    ) async throws -> (Result<T?, APIError>) {
        // mock data and response
        var json: String = ""
        
        if payloadType == BusinessResponse.self {
            json = mockJson
        }
        
        if json.isEmpty {
            return .failure(.noData)
        }
        
        do {
            if let data = json.data(using: .utf8) {
                let decodedResponse = try decoder.decode(payloadType, from: data)
                return .success(decodedResponse)
            }
            
            return .failure(.decodingError)
        } catch let error {
            print(error.localizedDescription)
            return .failure(.unknown)
        }
    }
    
    func fetchImage(urlPath: String) async throws -> UIImage? {
        guard let imagePath = urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        let cacheId = NSString(string: imagePath)
        
        // first check cache
        if let imageData = try await fetchDataBy(cacheId: cacheId) {
            return UIImage(data: imageData)
        } else {
            return try await fetchImageBy(cacheId: cacheId)
        }
    }
    
    func fetchDataBy(cacheId: NSString) async throws -> Data? {
        return cache.object(forKey: cacheId) as Data?
    }
    
    func fetchImageBy(cacheId: NSString) async throws -> UIImage? {
        if let image = UIImage(named: "pancakes"),
           let data = image.jpegData(compressionQuality: 1.0) {
            self.cache.setObject(data as NSData, forKey: cacheId)
            return image
        }
        return nil
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

let mockJson = """
{
  "businesses": [
    {
      "categories": [
        {
          "alias": "pizza",
          "title": "Pizza"
        },
        {
          "alias": "food",
          "title": "Food"
        }
      ],
      "image_url": "https://yelp-photos.yelpcorp.com/bphoto/b0mx7p6x9Z1ivb8yzaU3dg/o.jpg",
      "is_closed": true,
      "name": "Golden Boy Pizza",
      "phone": "+14159829738",
      "price": "$",
      "rating": 4
    },
    {
      "categories": [
        {
          "alias": "pizza",
          "title": "Pizza"
        },
        {
          "alias": "food",
          "title": "Food"
        }
      ],
      "image_url": "https://yelp-photos.yelpcorp.com/bphoto/b0mx7p6x9Z1ivb8yzaU3dg/o.jpg",
      "is_closed": true,
      "name": "Golden Boy Pizza 2",
      "phone": "+14159829738",
      "price": "$",
      "rating": 4
    }
  ]
}
"""

