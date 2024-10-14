//
//  APIError.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import Foundation

// MARK: defines all api errors used in app

enum APIError: Error {
    case httpError(code: Int)
    case decodingError
    case noData
    case noNetwork
    case badUrl
    case invalidRequest
    case unknown
}

extension APIError {
    var localizedError: String {
        switch self {
        case let .httpError(code):
            return NSLocalizedString("A Network Error occured: \(code.description)", comment: "")
        case .decodingError:
            return NSLocalizedString("A decoding Error occured", comment: "")
        case .noData:
            return NSLocalizedString("No data returned", comment: "")
        case .noNetwork:
            return NSLocalizedString("No internet connection", comment: "")
        case .badUrl:
            return NSLocalizedString("Invalid URL", comment: "")
        case .invalidRequest:
            return NSLocalizedString("Invalid request", comment: "")
        case .unknown:
            return NSLocalizedString("Oops! Something went wrong", comment: "")
        }
    }
}
