//
//  TestClipboardProvider.swift
//  InfiniteImageScrollTests
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
@testable import InfiniteImageScroll

/// A `ClipboardProvider` that can be used for testing.
final class TestClipboardProvider: ClipboardProvider {
    
    private let perform: (VisualImage) -> Void
    
    /**
     Creates a new receiver with the provided parameters
     
     - parameter perform: A closure that will called on every call to `store(visualImage:)`.
     - parameter image: The image passed to `store(visualImage:)`.
     */
    init(onStore perform: @escaping (_ image: VisualImage) -> Void) {
        self.perform = perform
    }
    
    func store(visualImage: VisualImage) {
        perform(visualImage)
    }
    
    static func alwaysSuccess() -> TestClipboardProvider {
        return .init(onStore: { _ in })
    }
}
