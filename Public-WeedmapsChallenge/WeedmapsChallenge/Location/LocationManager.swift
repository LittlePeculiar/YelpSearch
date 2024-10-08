//
//  LocationManager.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, LocationService {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    
    // Irvine, Ca
    private let defaultCoords = Coordinates(latitude: 33.669445, longitude: -117.823059)

    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAuthorization() async {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getLocation() async throws -> Coordinates {
        guard let last = self.location else {
            return defaultCoords
        }
        let coords = Coordinates(latitude: last.coordinate.latitude, longitude: last.coordinate.longitude)
        return coords
    }

}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task {
            switch status {
                case .notDetermined:
                   await requestAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                   locationManager.startUpdatingLocation()
                default:
                   self.location = nil
            }
        }
    }
}
