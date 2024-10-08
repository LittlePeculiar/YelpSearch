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
    
    private var api: APIService = API()
    private var locationManager = LocationManager.shared
    private var coords = Coordinates()
    
    init() {
        Task {
            await locationManager.requestAuthorization()
        }
    }
    
    // fetch by current location
    @MainActor func getCurrentLocation() async {
        do {
            self.coords = try await locationManager.getLocation()
            await fetch()
        } catch let error {
            print("error fetching coords: \(error.localizedDescription)")
            showError = true
        }
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
                print("failed to fetch data: \(error)")
                self.isLoading = false
                self.showError = true
                
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
            print("error fetching meals: \(error.localizedDescription)")
            self.isLoading = false
            self.showError = true
        }
    }
    
}
