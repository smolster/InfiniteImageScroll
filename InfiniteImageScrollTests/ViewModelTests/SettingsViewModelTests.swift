//
//  SettingsViewModelTests.swift
//  InfiniteImageScrollTests
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import XCTest
@testable import InfiniteImageScroll

class SettingsViewModelTests: XCTestCase {

    func testEnteringEmptySearchStringLeadsToResetToDefault() {
        let viewModel = SettingsViewModel.alwaysSuccess()
        
        let expectation = self.expectation(description: "should call")
        
        viewModel.inputs.viewDidLoad()
        viewModel.outputs.displaySettings = { newSettings in
            if newSettings.searchString == UserSettings.default.searchString {
                expectation.fulfill()
            }
        }
        viewModel.inputs.userUpdatedSearchStringText(to: "")
        
        wait(for: [expectation], timeout: 0.25)
    }

}

private extension SettingsViewModel {
    static func alwaysSuccess() -> SettingsViewModel {
        return .init(settingsProvider: TestUserSettingsProvider.alwaysSuccess())
    }
}
