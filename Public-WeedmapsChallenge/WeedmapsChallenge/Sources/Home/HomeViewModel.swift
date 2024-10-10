//
//  HomeViewModel.swift
//  WeedmapsChallenge
//
//  Created by Gina Mullins on 10/8/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import Foundation
import Combine

class HomeViewModel {
    @Published var businesses: [Business] = []
    @Published var isLoading: Bool = true
    @Published var showError: Bool = false
    
    private var locationManager = LocationManager.shared
    private var coords = Coordinates()
    
    var api: APIService = API()
    var errorMessage: String = ""
    
    init() {
        locationManager.delegate = self
    }
    
    // fetch by current location
    @MainActor func fetch(_ term: String = "") async {
        do {
            let results = try await api.fetchData(
                payloadType: BusinessResponse.self,
                from: APIEndpoint.searchBy(
                    term: term,
                    latitude: coords.latitude,
                    longitude: coords.longitude
                )
            )
            switch results {
            case .failure(let error):
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
                print("error fetching coords: \(errorMessage)")
                
            case .success(let result):
                print("success: \(String(describing: result?.businesses.count)) records")
                if let data = result?.businesses {
                    // sort
                    self.businesses = data.sorted(by: {
                        return $0.name < $1.name
                    })
                    self.isLoading = false
                }
            }
            
        } catch let error {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
            print("error fetching coords: \(errorMessage)")
        }
    }
    
}

extension HomeViewModel: LocationManagerDelegate {
    func handleLocationUpdates(coords: Coordinates?) {
        guard let newCoords = coords else { return }
        self.coords = Coordinates(latitude: newCoords.latitude, longitude: newCoords.longitude)
        Task {
            await fetch()
        }
    }
}
