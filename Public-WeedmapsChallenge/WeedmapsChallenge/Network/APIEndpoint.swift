//
//  APIEndpoint.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import Foundation

// MARK: defines all endpoints used in app

enum APIEndpoint: Hashable {
    case searchBy(latitude: Double, longitude: Double)
    case search(_ term: String)
}

extension APIEndpoint {
    private var baseUrl: String {
        "https://api.yelp.com/v3/businesses/"
    }
    
    var path: String {
        switch self {
        case .searchBy(let latitude, let longitude):
            return "\(baseUrl)matches?latitude=\(latitude)&longitude=\(longitude)&limit=15&match_threshold=default"
        case let .search(term):
            return "\(baseUrl)search?term=\(term)&sort_by=best_match&limit=15"
        }
    }
}
