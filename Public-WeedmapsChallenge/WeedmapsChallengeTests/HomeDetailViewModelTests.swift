//
//  HomeDetailViewModelTests.swift
//  WeedmapsChallengeTests
//
//  Created by Gina Mullins on 10/10/24.
//  Copyright © 2024 Weedmaps, LLC. All rights reserved.
//

import XCTest
@testable import WeedmapsChallenge

final class HomeDetailViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_HomeDetailViewModel_AtLoad() {
        let business = Business(
            name: "",
            rating: 0,
            categories: [],
            phone: "",
            price: "",
            url: "",
            imageURL: "",
            isClosed: false
        )
        
        // test HomeDetailViewModel init
        let viewModel = HomeDetailViewModel(business: business)
        XCTAssertNotNil(viewModel)
    }
}
