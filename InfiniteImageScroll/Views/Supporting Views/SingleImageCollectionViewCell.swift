//
//  SingleImageCollectionViewCell.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit
import FLAnimatedImage

final class SingleImageCollectionViewCell: UICollectionViewCell {
    
    /// Enumerates the different available configurations of the cell.
    enum Configuration {
        /// Blank, showing nothing.
        case blank
        
        /// Showing an activity indicator with the provided style.
        case loading(UIActivityIndicatorView.Style)
        
        /// Displaying an image, and providing optional long press gesture recognition. The provided `longPressAction` callback will only be called once per long press touch.
        case showingImage(VisualImage, longPressAction: (() -> Void)?)
        
        /// Displaying an error image.
        case showingError
    }
    
    @IBOutlet private weak var errorLabel: UILabel! {
        didSet { errorLabel.isHidden = true }
    }
    
    @IBOutlet private weak var imageView: FLAnimatedImageView! {
        didSet {
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressReceived(_:))))
        }
    }
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.isHidden = true
        }
    }
    
    private var hasCalledLongPressAction: Bool = false
    private var longPressAction: (() -> Void)?
    
    /// Access to the underlying image view's content mode. Default is `.scaleAspectFill`.
    var imageViewContentMode: UIView.ContentMode {
        get { return imageView.contentMode }
        set (newValue) { imageView.contentMode = newValue }
    }
    
    func configure(as configuration: Configuration) {
        switch configuration {
        case .blank:
            errorLabel.isHidden = true
            imageView.animatedImage = nil
            imageView.image = nil
            activityIndicator.isHidden = true
            longPressAction = nil
            
        case .loading(let style):
            errorLabel.isHidden = true
            imageView.animatedImage = nil
            imageView.image = nil
            longPressAction = nil
            activityIndicator.style = style
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            
        case .showingImage(let image, longPressAction: let action):
            errorLabel.isHidden = true
            activityIndicator.isHidden = true
            longPressAction = action
            
            switch image {
            case .still(let stillImage):
                imageView.animatedImage = nil
                imageView.image = stillImage
            case .animated(let animatedImage):
                imageView.image = nil
                imageView.animatedImage = animatedImage
            }
            
        case .showingError:
            imageView.animatedImage = nil
            imageView.image = nil
            longPressAction = nil
            activityIndicator.isHidden = true
            errorLabel.isHidden = false
            longPressAction = nil
        }
    }
    
    @objc private func longPressReceived(_ gesture: UILongPressGestureRecognizer) {
        // Long press is a continuous gesture, but we only want to call once. So, we run this little song and dance.
        if !hasCalledLongPressAction && gesture.state == .began {
            self.hasCalledLongPressAction = true
            self.longPressAction?()
        } else if hasCalledLongPressAction && gesture.state == .ended {
            self.hasCalledLongPressAction = false
        }
    }
}

extension SingleImageCollectionViewCell: NibLoadable, Reusable {
    static var reuseIdentifier: String { return "SingleImageCollectionViewCell" }
    static var nibName: String { return "SingleImageCollectionViewCell" }
}
