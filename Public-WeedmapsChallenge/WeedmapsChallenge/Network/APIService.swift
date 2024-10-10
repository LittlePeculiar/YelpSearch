//
//  APIService.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

/*
 Network Service Protocal
 */

import UIKit

protocol APIService {
    func fetchData<T: Decodable>(
        payloadType: T.Type,
        from endpoint: APIEndpoint,
        method: Method
    ) async throws -> (Result<T?, APIError>)
    
    func fetchImage(urlPath: String) async throws -> UIImage?
}

// satisfy protocol for default params
extension APIService {
    func fetchData<T: Decodable>(
        payloadType: T.Type,
        from endpoint: APIEndpoint
    ) async throws -> (Result<T?, APIError>) {
        return try await fetchData(payloadType: payloadType, from: endpoint, method: .GET)
    }
}

enum Method: String {
    case GET
    case POST
    case PUT
    case DELETE
}

