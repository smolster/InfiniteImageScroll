//
//  TestImageDataProvider.swift
//  InfiniteImageScrollTests
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
@testable import InfiniteImageScroll

/// An `ImageDataProvider` that can be used for testing.
final class TestImageDataProvider: PagingImageDataProvider {
    
    private let resultCreator: (ImageQueryFilter) -> Result<ImagePage, NetworkError>
    
    /**
     Creates a new receiver with the provided parameters.
     
     - parameter resultCreator: Closure that will be used to fulfill calls to `fetchImages(filter:count:offset:completion:)`.
     - parameter filter: The filter passed to `fetchImages(filter:count:offset:completion:)`.
     */
    init(resultCreator: @escaping (_ filter: ImageQueryFilter) -> Result<ImagePage, NetworkError>) {
        self.resultCreator = resultCreator
    }
    
    func fetchImages(filter: ImageQueryFilter, count: Int, offset: Int, completion: @escaping (Result<ImagePage, NetworkError>) -> Void) {
        completion(resultCreator(filter))
    }
    
    /**
     Returns an image data provider that always succeeds with the provided number of images, calling an optional `perform` closure when `fetchImages(filter:count:offset:completion:)` is called. Default number of images is 10.
     
     - parameter images: The number of images to return.
     - parameter perform: A closure to be called on every call to `fetchImages(filter:count:offset:completion:)`.
     */
    static func alwaysSuccess(images: Int = 10, onCallToFetch perform: (() -> Void)? = nil) -> TestImageDataProvider {
        return .init { _ in
            perform?()
            return .success(.init(
                totalEstimatedResults: 1000,
                imageCount: images,
                nextOffset: images+1,
                images: .init(repeating: .init(name: "Dummy", thumbnailURL: .dummy, contentURL: .dummy), count: images),
                suggestedPivotSearchString: "DUMMY")
            )
        }
    }
    
    /// An image data provider that always fails with the provided error.
    static func alwaysFailure(with error: NetworkError = .decodingError(NSError())) -> TestImageDataProvider {
        return .init { _ in
            return .failure(error)
        }
    }
}
