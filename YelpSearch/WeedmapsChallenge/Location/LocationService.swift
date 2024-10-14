//
//  LocationService.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

/*
 Location Service Protocal
 */

import Foundation
import CoreLocation

struct Coordinates {
  let latitude: Double
  let longitude: Double
    
    init(latitude: Double = 0, longitude: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

protocol LocationService {
  func getLocation() async
}
