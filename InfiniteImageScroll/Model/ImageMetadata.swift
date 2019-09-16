//
//  ImageMetadata.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/12/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// Metadata for an image.
struct ImageMetadata {
    /// The name text for the image.
    let name: String
    
    /// A URL for the thumbnail-sized version of the image.
    let thumbnailURL: URL
    
    /// A URL for the full-size version of the image.
    let contentURL: URL
}
