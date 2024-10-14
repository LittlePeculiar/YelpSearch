//
//  HomeDetailViewModel.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/9/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import Foundation
import Combine

class HomeDetailViewModel {
    @Published var business: Business
    
    init(business: Business) {
        self.business = business
    }
}
