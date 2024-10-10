//
//  LocationManager.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

/*
 handles location services authorization and fetching current location
 used for sending coordinate to api
 */

import Foundation
import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    // notify homeview when coords are set
    func handleLocationUpdates(coords: Coordinates?)
}

class LocationManager: NSObject, LocationService {
    static let shared = LocationManager()
    weak var delegate: LocationManagerDelegate?
    
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    
    // Irvine, Ca
    private let defaultCoords = Coordinates(latitude: 33.669445, longitude: -117.823059)

    override init() {
        super.init()
        
        locationManager.delegate = self
        Task {
            await requestAuthorization()
        }
    }
    
    func requestAuthorization() async {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getLocation() async {
        var coords = defaultCoords
        
        if let last = self.location {
            coords = Coordinates(
                latitude: last.coordinate.latitude,
                longitude: last.coordinate.longitude
            )
        }
        
        print("Location: \(coords)")
        delegate?.handleLocationUpdates(coords: coords)
    }

}

// MARK: Location Manager Delegate Methods

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        Task {
            location = locations.last
            await getLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager failed: \(error.localizedDescription)")
        delegate?.handleLocationUpdates(coords: defaultCoords)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            case .notDetermined:
               Task {
                   await requestAuthorization()
               }
            case .authorizedAlways, .authorizedWhenInUse:
               locationManager.startUpdatingLocation()
            default:
               delegate?.handleLocationUpdates(coords: defaultCoords)
        }
        
    }
}
