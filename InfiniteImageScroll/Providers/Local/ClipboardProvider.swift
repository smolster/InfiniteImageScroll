//
//  ClipboardProvider.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
import UIKit

/// An object that can be used to store images on the clipboard.
protocol ClipboardProvider {
    /**
     Synchronously stores the provided image on the clipboard.
     
     - parameter visualImage: The image to store.
     */
    func store(visualImage: VisualImage)
}

extension UIPasteboard: ClipboardProvider {
    func store(visualImage: VisualImage) {
        switch visualImage {
        case .still(let stillImage):
            self.image = stillImage
        case .animated(let animatedImage):
            self.setData(animatedImage.data, forPasteboardType: "kUTTypeGIF")
        }
    }
    
}
