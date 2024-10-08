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
    case searchBy(term: String, latitude: Double, longitude: Double)
}

extension APIEndpoint {
    private var baseUrl: String {
        "https://api.yelp.com/v3/businesses/"
    }
    
    var path: String {
        switch self {
        case .searchBy(let term, let latitude, let longitude):
            return "\(baseUrl)search?term=\(term)&latitude=\(latitude)&longitude=\(longitude)&limit=20"
        }
    }
}
