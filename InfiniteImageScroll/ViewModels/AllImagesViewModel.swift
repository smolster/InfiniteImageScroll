//
//  AllImagesViewModel.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/12/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
// Note: Normally, we wouldn't want to import UIKit in a ViewModel. But, one of our dependencies here is a `ClipboardProvider` in the form of `UIPasteboard`. So, this import is mainly an implementation detail.
import UIKit

typealias OutputFunction<Value> = (Value) -> Void

protocol AllImagesViewModelInputs: class {
    /// Call at the end of viewDidLoad.
    func viewDidLoad()
    
    /// Call in viewWillAppear.
    func viewWillAppear()
    
    /// Call when the user is nearing the bottom of the page. Safe to call multiple times in quick succession.
    func userNearingBottomOfPage()
    
    /// Call when the provided index will come into view. (collectionView(_:willDisplay:forItemAt:))
    func indicesWillComeIntoView(_ itemIndices: [Int])
    
    /// Call when the provided indices go out of view. (collectionView(_:didEndDisplaying:forItmeAt:))
    func indicesDidGoOutOfView(_ itemIndices: [Int])
    
    /// Call when the user long presses on the item at the provided index. Only call once per long press.
    func userLongPressedOnItem(at index: Int)
    
    /// Call when the user taps an item.
    func userTappedItem(at index: Int)
    
    /// Call when the user taps the "Settings" button.
    func userTappedSettingsButton()
    
}

protocol AllImagesViewModelOutputs: class {
    /// Outputs when the provided image should be shown at the provided index, if it is in view.
    var displayImageAtIndexIfInView: OutputFunction<(image: VisualImage, index: Int)>? { get set }
    
    /// Outputs when an error should be displayed at the provided index, if it is in view.
    var displayErrorAtIndexIfInView: OutputFunction<Int>? { get set }
    
    /// Outputs when the total number of items should be increased by the provided increment
    var increaseTotalItemsByIncrement: OutputFunction<Int>? { get set }
    
    /// Outputs when the total number of items should be set to 0.
    var decreaseTotalItemsToZero: OutputFunction<Void>? { get set }
    
    /// Outputs when the loading overlay state should be updated.
    var updateLoadingOverlayState: OutputFunction<AllImagesLoadingOverlayState>? { get set }
    
    /// Outputs when the user should be shown the full-screen single image view, using the provided view model.
    var showFullScreenImageViewWithViewModel: OutputFunction<FullScreenImageViewModelType>? { get set }
    
    /// Outputs when the user should be shown the Settings screen, using the provided view model.
    var showSettingsScreenWithViewModel: OutputFunction<SettingsViewModelType>? { get set }
    
    /// Outputs when the user should be shown the provided alert.
    var displayAlert: OutputFunction<UserAlert>? { get set }
}

protocol AllImagesViewModelType: class {
    var inputs: AllImagesViewModelInputs { get }
    var outputs: AllImagesViewModelOutputs { get }
}

final class AllImagesViewModel: AllImagesViewModelInputs, AllImagesViewModelOutputs, AllImagesViewModelType {
    
    var inputs: AllImagesViewModelInputs { return self }
    var outputs: AllImagesViewModelOutputs { return self }
    
    // MARK: - Dependencies
    
    /// Our metadata provider.
    private let imageDataProvider: PagingImageDataProvider
    
    /// Our image provider.
    private let imageProvider: ImageProvider
    
    /// Our metadata loader. Variable, since it may be swapped out if settings change.
    private var imageDataLoader: ForwardPagingImageDataLoader!
    
    /// Our settings provider.
    private let settingsProvider: UserSettingsProvider
    
    /// Our clipboardProvider.
    private let clipboardProvider: ClipboardProvider
    
    // MARK: - Private Properties.
    
    /// Current user settings.
    private var currentUserSettings: UserSettings!
    
    /// Tracks the total number of items available in the view. We use this to determine if the loader has loaded more items between calls to viewDidAppear.
    private var currentTotalItemCount: Int = 0
    
    /// Indicates if we are currently loading a metadata page.
    private var isLoadingMetadata = false
    
    init(
        imageDataProvider: PagingImageDataProvider = BingImageDataProvider(),
        imageProvider: ImageProvider = NetworkImageProvider(),
        settingsProvider: UserSettingsProvider = UserDefaultsSettingsProvider(),
        clipboardProvider: ClipboardProvider = UIPasteboard.general
    ) {
        self.imageDataProvider = imageDataProvider
        self.imageProvider = imageProvider
        self.settingsProvider = settingsProvider
        self.clipboardProvider = clipboardProvider
    }
    
    // MARK: - Outputs
    var displayImageAtIndexIfInView: OutputFunction<(image: VisualImage, index: Int)>?
    var displayErrorAtIndexIfInView: OutputFunction<Int>?
    var increaseTotalItemsByIncrement: OutputFunction<Int>?
    var decreaseTotalItemsToZero: OutputFunction<Void>?
    var updateLoadingOverlayState: OutputFunction<AllImagesLoadingOverlayState>?
    var showFullScreenImageViewWithViewModel: OutputFunction<FullScreenImageViewModelType>?
    var showSettingsScreenWithViewModel: OutputFunction<SettingsViewModelType>?
    var displayAlert: OutputFunction<UserAlert>?
    
    // MARK: - Inputs
    func viewDidLoad() {
        // Need to fetch settings and store an image data loader.
        self.currentUserSettings = settingsProvider.retrieveStoredSettings()
        self.imageDataLoader = self.updatedDataLoader()
        
        // Now, start the load process sequence.
        self.outputs.updateLoadingOverlayState?(.loading(.loadingImages))
        self.loadAndDisplayNextPage(completion: { wasSuccess in
            self.outputs.updateLoadingOverlayState?(.finished(.loadingImages, wasSuccess: wasSuccess))
        })
    }
    
    func viewWillAppear() {
        // We need to determine if the loader has loaded more metadata since the last viewWillAppear call. If so, we need to update our view. This could happen if a new page load happens in the full screen view.
        if imageDataLoader.loadedMetadata.count > currentTotalItemCount {
            self.increaseTotalItemsByIncrement?(imageDataLoader.loadedMetadata.count - currentTotalItemCount)
            currentTotalItemCount = imageDataLoader.loadedMetadata.count
        }
        
        // Also, need to know if settings have changed. If so, we need to reload.
        let upToDateSettings = settingsProvider.retrieveStoredSettings()
        if upToDateSettings != currentUserSettings {
            // Settings were changed. So, need to...
            // Update our local settings.
            self.currentUserSettings = upToDateSettings
            
            // Show loading state.
            self.outputs.updateLoadingOverlayState?(.loading(.loadingImages))
            
            // Swap out a new loader.
            self.imageDataLoader = self.updatedDataLoader()
            
            // Decrement the total cells back to 0.
            self.outputs.decreaseTotalItemsToZero?(())
            
            // Kick off page loading sequence.
            self.loadAndDisplayNextPage(completion: { wasSuccess in
                self.outputs.updateLoadingOverlayState?(.finished(.loadingImages, wasSuccess: wasSuccess))
            })
        }
    }
    
    func userNearingBottomOfPage() {
        self.loadAndDisplayNextPage(completion: nil)
    }
    
    func indicesWillComeIntoView(_ itemIndices: [Int]) {
        itemIndices.forEach { index in
            self.imageProvider.fetchImage(at: imageDataLoader.loadedMetadata[index].thumbnailURL, then: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let image):
                    self.outputs.displayImageAtIndexIfInView?((image, index))
                case .failure:
                    self.outputs.displayErrorAtIndexIfInView?(index)
                }
            })
        }
    }
    
    func indicesDidGoOutOfView(_ itemIndices: [Int]) {
        itemIndices.forEach { index in
            guard index < imageDataLoader.loadedMetadata.endIndex else { return }
            self.imageProvider.cancelImageLoad(from: imageDataLoader.loadedMetadata[index].thumbnailURL)
        }
    }
    
    func userLongPressedOnItem(at index: Int) {
        self.outputs.updateLoadingOverlayState?(.loading(.copying))
        
        // Kick off full-size load.
        self.imageProvider.fetchImage(at: imageDataLoader.loadedMetadata[index].contentURL) { result in
            switch result {
            case .success(let image):
            // Successful fetch, put that bad boy on the clipboard! We update the state right away, since copying to the clipboard can take a non-negligible amount of time.
                self.outputs.updateLoadingOverlayState?(.finished(.copying, wasSuccess: true))
                self.clipboardProvider.store(visualImage: image)
                
            case .failure:
                self.outputs.updateLoadingOverlayState?(.finished(.copying, wasSuccess: false))
            }
        }
    }
    
    func userTappedItem(at index: Int) {
        self.outputs.showFullScreenImageViewWithViewModel?(FullScreenImageViewModel(
            centerIndex: index,
            imageProvider: self.imageProvider,
            imageDataLoader: self.imageDataLoader,
            clipboardProvider: self.clipboardProvider
        ))
    }
    
    func userTappedSettingsButton() {
        self.outputs.showSettingsScreenWithViewModel?(SettingsViewModel(settingsProvider: self.settingsProvider))
    }
    
    // MARK: - Private Functions
    
    /**
     Loads and displays the next page from the data loader.
     
     - parameter completion: A closure that will be called once the result of the page load is displayed.
     - parameter wasSuccess: Indicates if the page load was successful.
     */
    private func loadAndDisplayNextPage(completion: ((_ wasSuccess: Bool) -> Void)?) {
        // We need to avoid calling multiple times in quick succession.
        guard isLoadingMetadata == false else { return }
        isLoadingMetadata = true
        
        imageDataLoader.loadNextPage { [weak self] result in
            guard let self = self else { return }
            self.isLoadingMetadata = false
            switch result {
            case .success(let imageSet):
                // Just tell the view that our page size has increased. The calls to actually load these images will come from `indicesWillComeIntoView(_:)`. Call completion.
                self.outputs.increaseTotalItemsByIncrement?(imageSet.imageCount)
                self.currentTotalItemCount += imageSet.imageCount
                completion?(true)
                
            case .failure(let networkError):
                // Display a user-friendly alert.
                self.displayAlert?(imageDataNetworkErrorAlert(
                    networkError: networkError,
                    okAction: {
                        completion?(false)
                    },
                    retryAction: { [weak self] in
                        self?.loadAndDisplayNextPage(completion: completion)
                    }
                ))
            }
        }
    }
    
    /// Returns an unused image data loader parameterized with up-to-date settings.
    private func updatedDataLoader() -> ForwardPagingImageDataLoader {
        let settings = settingsProvider.retrieveStoredSettings()
        return ForwardPagingImageDataLoader(
            provider: self.imageDataProvider,
            filter: ImageQueryFilter(searchString: settings.searchString, animatedImagesOnly: settings.gifModeOn, facesOnly: settings.faceModeOn),
            preferredPageSize: 150
        )
    }
}

/// Enumerates the different states of the AllImages loading overlay.
enum AllImagesLoadingOverlayState: Equatable {
    /// Loading and displaying text. Interaction with collection view disabled.
    case loading(Activity)
    /// Finished loading and displaying completion message. Hide after showing. Interaction with collection view enabled.
    case finished(Activity, wasSuccess: Bool)
    
    /// Enumerates the activities that warrant the loading overlay.
    enum Activity: Equatable {
        /// Copying an image to the clipboard.
        case copying
        /// Loading more images into the grid.
        case loadingImages
    }
}
