//
//  HomeDetailViewModel.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/9/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import Foundation

enum WebOption {
    case openSafari, openWebkit
    
    var title: String {
        switch self {
            case .openSafari: return "Open Safari"
            case .openWebkit: return "Open WebKit"
        }
    }
}

class HomeDetailViewModel {
    @Published var webObtion: WebOption
    var business: Business
    
    init(business: Business, webObtion: WebOption) {
        self.business = business
        self.webObtion = webObtion
    }
}
