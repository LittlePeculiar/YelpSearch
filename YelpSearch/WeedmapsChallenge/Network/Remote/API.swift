//
//  API.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import UIKit

/*
 for making all api calls
 fetch function takes
    model: codable struct
    endpoint: API endpoint
    method: default is GET
 
 returns
    Codable Model
 */

typealias NetworkResult = (data: Data, response: URLResponse)


class API: APIService {
    
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let cache = NSCache<NSString, NSData>()
    
    init() {
        let sessionConfig = URLSessionConfiguration.default
        session = URLSession(configuration: sessionConfig)
    }
    
}

extension API {
    func fetchData<T: Decodable>(
        payloadType: T.Type,
        from endpoint: APIEndpoint,
        method: Method
    ) async throws -> (Result<T?, APIError>) {
        
        if let request = try getUrlRequest(endpoint: endpoint, method: method) {
            do {
                let result: NetworkResult = try await session.data(for: request, delegate: nil)
                guard let response = result.response as? HTTPURLResponse else {
                    return .failure(.noData)
                }
                switch response.statusCode {
                case 200...299:
                    guard let decodedResponse = try? decoder.decode(payloadType, from: result.data) else {
                        return .failure(.decodingError)
                    }
                    return .success(decodedResponse)
                default:
                    print(response.statusCode)
                    return .failure(.httpError(code: response.statusCode))
                }
            } catch {
                return .failure(.unknown)
            }
            
        }
        
        return .failure(.invalidRequest)
    }
    
    private func getUrlRequest(endpoint: APIEndpoint, method: Method) throws -> URLRequest? {
        var headers: [String: String] = [:]
        headers["Authorization"] = "Bearer \(Constants.apiKey)"
        headers["accept"] = "application/json"

        print("headers: \(headers)")
        print("path: \(endpoint.path)")
        guard let url = URL(string: endpoint.path) else {
            throw APIError.badUrl
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        
        headers.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        return urlRequest
    }
    
    func fetchImage(urlPath: String) async throws -> UIImage? {
        guard let imagePath = urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        let cacheId = NSString(string: imagePath)
        
        // first check cache
        if let imageData = cache.object(forKey: cacheId) as Data? {
            return UIImage(data: imageData)
        } else {
            // image not yet saved - fetch from api
            guard let url = URL(string: imagePath) else {
                return nil
            }
            
            let result: NetworkResult = try await session.data(from: url, delegate: nil)
            let imageData = result.data
            
            if let image = UIImage(data: imageData),
               let data = image.jpegData(compressionQuality: 1.0) {
                self.cache.setObject(data as NSData, forKey: cacheId)
                return image
            }
        }
        return nil
    }
}

extension Encodable {
    func getJsonData() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}

