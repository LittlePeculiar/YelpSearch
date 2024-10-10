//
//  HomeViewModelTests.swift
//  WeedmapsChallengeTests
//
//  Created by Gina Mullins on 10/10/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import XCTest
@testable import WeedmapsChallenge

final class HomeViewModelTests: XCTestCase {
    
    let coords = Coordinates(latitude: 33.669445, longitude: -117.823059)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_HomeViewModel_FetchAtLoad() {
        
        let expectation = self.expectation(description: "Test Fetching api")
        
        let api = MockAPI()
        Task {
            do {
                let results = try await api.fetchData(
                    payloadType: BusinessResponse.self,
                    from: APIEndpoint.searchBy(
                        term: "",
                        latitude: coords.latitude,
                        longitude: coords.longitude,
                        limit: 20,
                        offset: 0
                    )
                )
                switch results {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                    
                case .success(let result):
                    print("success: \(String(describing: result?.businesses.count)) records")
                    if let businesses = result?.businesses {
                        XCTAssertEqual(businesses.count, 2)
                        
                        if let business = businesses.first {
                            XCTAssertEqual(business.name, "Golden Boy Pizza")
                            XCTAssertEqual(business.phone, "+14159829738")
                            XCTAssertEqual(business.price, "$")
                            XCTAssertEqual(business.rating, 4)
                            if let thumb = business.imageURL {
                                XCTAssertFalse(thumb.isEmpty)
                            } else {
                                XCTAssertNil(business.imageURL)
                            }
                        }
                        expectation.fulfill()
                        
                    } else {
                        XCTAssertNil(result)
                    }
                }
                
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func test_HomeViewModel_FetchWithTerm() {
        
        let expectation = self.expectation(description: "Test Fetching api")
        
        let api = MockAPI()
        Task {
            do {
                let results = try await api.fetchData(
                    payloadType: BusinessResponse.self,
                    from: APIEndpoint.searchBy(
                        term: "Food",
                        latitude: coords.latitude,
                        longitude: coords.longitude,
                        limit: 20,
                        offset: 0
                    )
                )
                switch results {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                    
                case .success(let result):
                    print("success: \(String(describing: result?.businesses.count)) records")
                    if let businesses = result?.businesses {
                        XCTAssertEqual(businesses.count, 2)
                        
                        if let business = businesses.first {
                            XCTAssertEqual(business.name, "Golden Boy Pizza")
                            XCTAssertEqual(business.phone, "+14159829738")
                            XCTAssertEqual(business.price, "$")
                            XCTAssertEqual(business.rating, 4)
                            if let thumb = business.imageURL {
                                XCTAssertFalse(thumb.isEmpty)
                            } else {
                                XCTAssertNil(business.imageURL)
                            }
                        }
                        expectation.fulfill()
                        
                    } else {
                        XCTAssertNil(result)
                    }
                }
                
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

}
