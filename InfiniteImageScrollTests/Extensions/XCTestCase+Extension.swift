//
//  XCTestCase+Extension.swift
//  InfiniteImageScrollTests
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import XCTest

extension XCTestCase {
    func invertedExpectation(description: String) -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        expectation.isInverted = true
        return expectation
    }
}
