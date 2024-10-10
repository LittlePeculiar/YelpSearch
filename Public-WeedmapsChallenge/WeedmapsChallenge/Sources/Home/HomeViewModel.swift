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
    @Published var isLoading: Bool = true
    @Published var showError: Bool = false
    
    private var locationManager = LocationManager.shared
    private var coords = Coordinates()
    private var businesses: [Business] = []
    
    var api: APIService = API()
    var errorMessage: String = "please try again later"
    var searchTerm: String = ""
    var offset: Int = 0
    
    init() {
        locationManager.delegate = self
    }
    
    // fetch api
    @MainActor func fetch(_ term: String = "") async {
        do {
            searchTerm = term
            isLoading = true
            let results = try await api.fetchData(
                payloadType: BusinessResponse.self,
                from: APIEndpoint.searchBy(
                    term: term,
                    latitude: coords.latitude,
                    longitude: coords.longitude,
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
                    // sort
                    let new = data.sorted(by: {
                        return $0.name < $1.name
                    })
                    
                    // keep copy for resetting without calling api again
                    if businesses.isEmpty {
                        businesses = new
                        resetDisplayData()
                    } else {
                        displayBusinesses = new
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
        offset = 0
        searchTerm = ""
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
