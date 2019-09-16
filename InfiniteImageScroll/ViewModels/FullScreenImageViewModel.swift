//
//  FullScreenImageViewModel.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
import UIKit

protocol FullScreenImageViewModelInputs: class {
    /// Call at the end of viewDidLoad.
    func viewDidLoad()
    
    /// Call when the provided index will come into view. (collectionView(_:willDisplay:forItemAt:))
    func indicesWillComeIntoView(_ itemIndices: [Int])
    
    /// Call when the provided indices go out of view. (collectionView(_:didEndDisplaying:forItmeAt:))
    func indicesDidGoOutOfView(_ itemIndices: [Int])
    
    /// Call when the user long presses on the item at the provided index. Only call once per long press.
    func userLongPressedOnItem(at index: Int, image: VisualImage)
    
    /// Call when the user taps anywhere on the screen.
    func userTappedScreen()
}

protocol FullScreenImageViewModelOutputs: class {
    /// The initial total count of cells to display.
    var initialTotalCellCount: Int { get }
    
    /// Outputs when the provided state should be displayed at the provided index, if it is in view.
    var displayImageStateAtIndexIfInView: OutputFunction<(state: FullScreenImageState, index: Int)>? { get set }
    
    /// Outputs when the number of displayed items should be increased by the provided increment
    var increasePageSizeByIncrement: OutputFunction<Int>? { get set }
    
    /// Outputs when the view should be scrolled to the provided index, without animation.
    var scrollImmediatelyToItemAtIndex: OutputFunction<Int>? { get set }
    
    /// Outputs when the user should be shown a brief confirmation overlay for a successful image copy.
    var showBriefConfirmationOverlayForSuccessfulCopy: OutputFunction<Void>? { get set }
    
    /// Outputs when the user should be shown the provided alert.
    var displayAlert: OutputFunction<UserAlert>? { get set }
    
    /// Outputs when the view should be dismissed.
    var dismiss: OutputFunction<Void>? { get set }
}

protocol FullScreenImageViewModelType: class {
    var inputs: FullScreenImageViewModelInputs { get }
    var outputs: FullScreenImageViewModelOutputs { get }
}

final class FullScreenImageViewModel: FullScreenImageViewModelInputs, FullScreenImageViewModelOutputs, FullScreenImageViewModelType {
    
    var inputs: FullScreenImageViewModelInputs { return self }
    var outputs: FullScreenImageViewModelOutputs { return self }
    
    /// Our image provider.
    private let imageProvider: ImageProvider
    
    /// Our image data loader.
    private let imageDataLoader: ForwardPagingImageDataLoader
    
    private let clipboardProvider: ClipboardProvider
    
    /// The index of the initial image to view.
    private let initialCenterIndex: Int
    
    init(
        centerIndex: Int,
        imageProvider: ImageProvider,
        imageDataLoader: ForwardPagingImageDataLoader,
        clipboardProvider: ClipboardProvider
    ) {
        self.initialCenterIndex = centerIndex
        self.initialTotalCellCount = imageDataLoader.loadedMetadata.count
        self.imageProvider = imageProvider
        self.imageDataLoader = imageDataLoader
        self.clipboardProvider = clipboardProvider
    }
    
    // MARK: - Outputs
    let initialTotalCellCount: Int
    var displayImageStateAtIndexIfInView: OutputFunction<(state: FullScreenImageState, index: Int)>?
    var increasePageSizeByIncrement: OutputFunction<Int>?
    var scrollImmediatelyToItemAtIndex: OutputFunction<Int>?
    var showBriefConfirmationOverlayForSuccessfulCopy: OutputFunction<Void>?
    var displayAlert: OutputFunction<UserAlert>?
    var dismiss: OutputFunction<Void>?
    
    // MARK: - Inputs
    func viewDidLoad() {
        outputs.scrollImmediatelyToItemAtIndex?(initialCenterIndex)
    }
    
    func indicesWillComeIntoView(_ itemIndices: [Int]) {
        // If last index, we need to load the next page. AND update the all images view.
        if itemIndices.last! == imageDataLoader.loadedMetadata.endIndex-1 {
            self.loadNextPage()
        }
        
        itemIndices.forEach { self.outputs.displayImageStateAtIndexIfInView?((.loading, $0)) }
        itemIndices.forEach { index in
            self.imageProvider.fetchImage(at: imageDataLoader.loadedMetadata[index].contentURL, then: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let image):
                    self.outputs.displayImageStateAtIndexIfInView?((.displaying(image), index))
                case .failure:
                    self.outputs.displayImageStateAtIndexIfInView?((.error, index))
                }
            })
        }
    }
    
    func indicesDidGoOutOfView(_ itemIndices: [Int]) {
        itemIndices.forEach { self.imageProvider.cancelImageLoad(from: imageDataLoader.loadedMetadata[$0].contentURL) }
    }
    
    func userLongPressedOnItem(at index: Int, image: VisualImage) {
        // So, putting this full-size image on the clipboard can sometimes take a while (~0.5 seconds in a bad scenario). But, it will always succeed. So, we go ahead and show the banner to the user right away, to avoid confusing them.
        self.outputs.showBriefConfirmationOverlayForSuccessfulCopy?(())
        clipboardProvider.store(visualImage: image)
    }
    
    func userTappedScreen() {
        self.outputs.dismiss?(())
    }
    
    // MARK: - Private Functions
    
    func loadNextPage() {
        self.imageDataLoader.loadNextPage { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let page):
                self.outputs.increasePageSizeByIncrement?(page.imageCount)
            case .failure(let networkError):
                self.outputs.displayAlert?(imageDataNetworkErrorAlert(
                    networkError: networkError,
                    okAction: nil,
                    retryAction: { [weak self] in
                        self?.loadNextPage()
                    }
                ))
            }
        }
    }
    
}

/// Enumerates the different states of an image display in the full screen view.
enum FullScreenImageState {
    /// The image is loaded and displaying.
    case displaying(VisualImage)
    /// The image is loading. A loading animation is displaying.
    case loading
    /// The image failed to load. An error is displaying.
    case error
}
