//
//  PagingImageDataProvider.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/12/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// An object that can be used to asynchronously fetch paging-supported image metadata.
protocol PagingImageDataProvider {
    /**
     Asynchronously fetches image metadata according to the provided parameters, calling a completion block when the images are retrieved or an error is encountered.
     
     - Note: The number of returned images will be less than or equal to `count`.
     
     - Parameters:
        - filter: The filter information to use when querying results.
        - count: The number of images desired. See note above.
        - offset: The indexing offset at which to fetch.
        - completion: A completion block to handle the result.
        - result: A `Result` containing either the retrieved image metadata set, or an error.
     */
    func fetchImages(filter: ImageQueryFilter, count: Int, offset: Int, completion: @escaping (_ result: Result<ImagePage, NetworkError>) -> Void)
}

// MARK: - Supporting Objects

/// Describes query filter information.
struct ImageQueryFilter {
    /// The search string.
    let searchString: String
    /// Indicates whether or not to filter for animated images.
    let animatedImagesOnly: Bool
    /// Indicates whether or not to filter for face images.
    let facesOnly: Bool
}

/// Describes a retrieved group of images.
struct ImagePage {
    /// The total number of estimated results.
    let totalEstimatedResults: Int
    
    /// The number of elements in the `images` array.
    let imageCount: Int
    
    /// The next offset after this set of images.
    let nextOffset: Int
    
    /// The images retrieved.
    let images: [ImageMetadata]
    
    /// A suggested pivot search string.
    let suggestedPivotSearchString: String?
}
