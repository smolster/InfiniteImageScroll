//
//  TestImageProvider.swift
//  InfiniteImageScrollTests
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
import UIKit
@testable import InfiniteImageScroll

/// An `ImageProvider` that can be used for testing.
final class TestImageProvider: ImageProvider {
    
    private let resultCreator: (URL) -> Result<VisualImage, NetworkError>
    private let cancelCalledCallback: (URL) -> Void
    
    /**
     Creates a new receiver with the provided parameters
     
     - parameter resultCreator: A closure that will be used to fulfill calls to `fetchImages(url:completion:)`.
     - parameter url: The URL passed to `fetchImages(url:completion:)`.
     - parameter cancelCalledCallback: A closure that will be called anytime `cancelImageLoad(url:)` is called.
     - parameter cancelledURL: The URL passed to `cancelImageLoad(url:)`.
     */
    init(resultCreator: @escaping (_ url: URL) -> Result<VisualImage, NetworkError>, cancelCalledCallback: @escaping (_ cancelledURL: URL) -> Void) {
        self.resultCreator = resultCreator
        self.cancelCalledCallback = cancelCalledCallback
    }
    
    func fetchImage(at url: URL, then completion: @escaping (Result<VisualImage, NetworkError>) -> Void) {
        completion(resultCreator(url))
    }
    
    func cancelImageLoad(from url: URL) {
        cancelCalledCallback(url)
    }
    
    /**
     Returns an image provider that always succeeds with the provided image, calling an optional `fetchCalled` closure on every call to `fetchImages(url:completion:)` is called, and an option `cancelCalled` closure on every call to `cancelImageLoad(url:)`.
     
     - parameter image: The image to return.
     - parameter fetchCalled: A closure to be called on every call to `fetchImages(url:completion:)`.
     - parameter cancelCalled: A closure to be called on every call to `cancelImageLoad(url:)`
     */
    static func alwaysSuccess(with image: VisualImage = .still(UIImage()), onCallToFetch fetchCalled: (() -> Void)? = nil, onCallToCancel cancelCalled: (() -> Void)? = nil) -> TestImageProvider {
        return .init(resultCreator: { _ in
            fetchCalled?()
            return .success(image)
        }, cancelCalledCallback: { _ in
            cancelCalled?()
        })
    }
    
    static func alwaysFailure(with error: NetworkError = .decodingError(NSError())) -> TestImageProvider {
        return .init(resultCreator: { _ in
            return .failure(error)
        }, cancelCalledCallback: { _ in
        })
    }
}
