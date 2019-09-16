//
//  ImageProvider.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
import UIKit

/// An object that can be used to fetch individual images from a `URL`.
protocol ImageProvider {
    /**
     Loads an image from a provided URL, calling a completion handler on sucessful image load or on encountering an error.
     
     - Parameters:
        - url: The image's URL.
        - completion: A completion handler, called on successful load or error.
        - result: The result of the image load.
     */
    func fetchImage(at url: URL, then completion: @escaping (_ result: Result<VisualImage, NetworkError>) -> Void)
    
    /// Attempts to cancel an image load at the provided URL.
    func cancelImageLoad(from url: URL)
}
