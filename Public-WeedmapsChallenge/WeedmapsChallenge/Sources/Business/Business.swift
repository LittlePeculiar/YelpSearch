//
//  Copyright © 2022 Weedmaps, LLC. All rights reserved.
//

import Foundation

struct BusinessResponse: Codable {
    let businesses: [Business]
}

struct Business: Codable {
    let name: String
    let rating: Int
    let categories: [Category]
    let phone: String?
    let price: String?
    let imageURL: String
    let isClosed: Bool
    
    private enum CodingKeys: String, CodingKey {
        case name, rating, categories, phone, price, imageURL = "image_url", isClosed = "is_closed"
    }
}

struct Category: Codable {
    let alias: String
    let title: String
}
