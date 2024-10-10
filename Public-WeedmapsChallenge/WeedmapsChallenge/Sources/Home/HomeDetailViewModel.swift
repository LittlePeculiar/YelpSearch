//
//  HomeDetailViewModel.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/9/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import Foundation

enum WebOptions {
    case openSafari, openWebkit
    
    var title: String {
        switch self {
            case .openSafari: return "Open Safari"
            case .openWebkit: return "Open WebKit"
        }
    }
}

class HomeDetailViewModel {
    var businesses: Business
    
    init(businesses: Business) {
        self.businesses = businesses
    }
}
