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
    @Published var displayBusinesses: [Business] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    
    private var locationManager = LocationManager.shared
    private var coords = Coordinates()
    private var businesses: [Business] = []
    
    var api: APIService
    var errorMessage: String = "please try again later"
    var offset: Int = 0
    var limit: Int = 20
    
    init(api: APIService = API()) {
        self.api = api
        locationManager.delegate = self
    }
    
    // fetch api
    @MainActor func fetch(_ term: String = "") async {
        guard !isLoading else { return }
        
        do {
            isLoading = true
            let results = try await api.fetchData(
                payloadType: BusinessResponse.self,
                from: APIEndpoint.searchBy(
                    term: term,
                    latitude: coords.latitude,
                    longitude: coords.longitude,
                    limit: limit,
                    offset: offset
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
                    // keep copy for resetting without calling api again
                    if businesses.isEmpty {
                        businesses = data
                        resetDisplayData()
                    } else {
                        if offset > 0 {
                            // fetching more records
                            businesses.append(contentsOf: data)
                            displayBusinesses = businesses
                        } else {
                            displayBusinesses = data
                        }
                    }
                    
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
    
    func resetDisplayData() {
        displayBusinesses = businesses
    }
    
}

extension HomeViewModel: LocationManagerDelegate {
    // called at launch when location is determined
    func handleLocationUpdates(coords: Coordinates?) {
        guard let newCoords = coords else { return }
        self.coords = Coordinates(latitude: newCoords.latitude, longitude: newCoords.longitude)
        Task {
            await fetch()
        }
    }
}
