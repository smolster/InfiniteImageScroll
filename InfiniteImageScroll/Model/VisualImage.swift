//
//  VisualImage.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit
import FLAnimatedImage

/// Represents a visualized image (e.g. a `UIImage`).
enum VisualImage {
    /// A still image.
    case still(UIImage)
    
    /// An animated image.
    case animated(FLAnimatedImage)
}

extension VisualImage {
    init?(data: Data) {
        if let animatedImage = FLAnimatedImage(animatedGIFData: data) {
            self = .animated(animatedImage)
        } else if let stillImage = UIImage(data: data) {
            self = .still(stillImage)
        } else {
            return nil
        }
    }
}
