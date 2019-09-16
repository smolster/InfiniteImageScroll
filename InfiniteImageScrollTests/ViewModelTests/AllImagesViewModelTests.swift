//
//  AllImagesViewModelTests.swift
//  InfiniteImageScrollTests
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import XCTest
@testable import InfiniteImageScroll

final class AllImagesViewModelTests: XCTestCase {
    
    /// Tests that a failed initial load leads to an alert.
    func testFailedInitialLoadLeadsToAler() {
        let viewModel = AllImagesViewModel(imageDataProvider: TestImageDataProvider.alwaysFailure())
        
        let testSuccessExpectation = self.expectation(description: "success")
        let testFailureExpectation = self.invertedExpectation(description: "failure")
        
        viewModel.outputs.increaseTotalItemsByIncrement = { _ in
            testFailureExpectation.fulfill()
        }
        
        viewModel.outputs.displayAlert = { _ in
            testSuccessExpectation.fulfill()
        }
        
        viewModel.viewDidLoad()
        
        wait(for: [testSuccessExpectation, testFailureExpectation], timeout: 0.25)
    }
    
    /// Tests that scrolling to the bottom of the page leads to the correct cell increment, if the load is successful.
    func testScrollToBottomOfPageLeadsToCorrectCellIncrementOnSuccessfulLoad() {
        let viewModel = AllImagesViewModel(imageDataProvider: TestImageDataProvider.alwaysSuccess(images: 15))
        
        let testSuccessExpectation = self.expectation(description: "success")
        let testFailureExpectation = self.invertedExpectation(description: "failure")
        
        viewModel.viewDidLoad()
        
        viewModel.outputs.increaseTotalItemsByIncrement = { increment in
            if increment == 15 {
                testSuccessExpectation.fulfill()
            } else {
                testFailureExpectation.fulfill()
            }
        }
        viewModel.inputs.userNearingBottomOfPage()
        
        wait(for: [testSuccessExpectation, testFailureExpectation], timeout: 0.25)
    }
    
    /// Tests that the loading overlay is shown, then hidden on a successful long press.
    func testLoadingOverlayShownAndDismissedOnLongPress() {
        let viewModel = AllImagesViewModel.testSuccess()
        
        let handler = OutputRecorder<AllImagesLoadingOverlayState>()
        
        viewModel.inputs.viewDidLoad()
        viewModel.outputs.updateLoadingOverlayState = handler.record
        viewModel.inputs.userLongPressedOnItem(at: 0)
        
        XCTAssert(handler.recordedValues == [.loading(.copying), .finished(.copying, wasSuccess: true)], "Failed. Received values: \(handler.recordedValues)")
        
    }
    
    /// Tests that a long press leads to a clipboard call.
    func testLongPressLeadsToClipboardProviderCall() {
        let expectation = self.expectation(description: "should call")
        let viewModel = AllImagesViewModel.testSuccess(clipboardProvider: TestClipboardProvider(onStore: { _ in
            expectation.fulfill()
        }))
        
        viewModel.outputs.increaseTotalItemsByIncrement = { [unowned viewModel] increment in
            viewModel.inputs.userLongPressedOnItem(at: 0)
        }
        
        viewModel.inputs.viewDidLoad()
        
        wait(for: [expectation], timeout: 0.25)
    }
}

private extension AllImagesViewModel {
    static func testSuccess(
        imageDataProvider: PagingImageDataProvider = TestImageDataProvider.alwaysSuccess(),
        imageProvider: ImageProvider = TestImageProvider.alwaysSuccess(),
        settingsProvider: UserSettingsProvider = TestUserSettingsProvider.alwaysSuccess(),
        clipboardProvider: ClipboardProvider = TestClipboardProvider.alwaysSuccess()
    ) -> AllImagesViewModel {
        return .init(imageDataProvider: imageDataProvider, imageProvider: imageProvider, settingsProvider: settingsProvider, clipboardProvider: clipboardProvider)
    }
}
