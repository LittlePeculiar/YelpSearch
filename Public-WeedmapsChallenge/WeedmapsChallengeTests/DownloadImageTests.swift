//
//  DownloadImageTests.swift
//  WeedmapsChallengeTests
//
//  Created by Gina Mullins on 10/10/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import XCTest
@testable import WeedmapsChallenge

final class DownloadImageTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_DownloadImage() {
        let expectation = self.expectation(description: "Test image caching")
        
        let api = MockAPI()
        
        // fetch image to setup cache
        Task {
            let image = try await api.fetchImageBy(cacheId: "TestCache")
            XCTAssertNotNil(image)
            
            let data = try await api.fetchDataBy(cacheId: "TestCache")
            XCTAssertNotNil(data)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
    }

}
