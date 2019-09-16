//
//  ForwardPagingImageDataLoader.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// An object that can be used in conjuction with a `PagingImageDataProvider` to page through results.
final class ForwardPagingImageDataLoader {
    
    /// Our data provider.
    private let provider: PagingImageDataProvider
    
    /// The full list of loaded image metadata.
    private(set) var loadedMetadata: [ImageMetadata] = []
    
    /// Our preferred page size.
    private let preferredPageSize: Int
    
    /// The current search string.
    private var currentSearchString: String
    
    /// Settings to be used for filtering.
    private let filterSettings: (animatedImagesOnly: Bool, facesOnly: Bool)
    
    /// The next offset to use for loading.
    private var nextOffset: Int = 0
    
    /// The total estimated results for the current search string.
    private var totalResultsForCurrentSearchString: Int?
    
    /// Indicates if there are more available results.
    private var moreResultsAvailable: Bool = true
    
    /**
     Creates a new receiver using the provided parameters.
     
     The provided `ImageSearchFilter`'s `searchString` is only used as an initial search string. Once all of the results for the initial string have been paged through, paging will begin again, using a pivot suggestion.
     
     - Parameters:
        - provider: The `PagingImageDataProvider` to use to load results. Will be retained.
        - filter: The `ImageSearchFilter` to use for creating search queries.
        - preferredPageSize: The preferred number of results to load per page. Actual number of results may be fewer.
     */
    init(provider: PagingImageDataProvider, filter: ImageQueryFilter, preferredPageSize: Int) {
        self.provider = provider
        self.currentSearchString = filter.searchString
        self.filterSettings = (filter.animatedImagesOnly, filter.facesOnly)
        self.preferredPageSize = preferredPageSize
    }
    
    /**
     Asynchronously loads the next page of the results, calling a completion handler on successful load or an error.
     
     When calling this function continuously, only make a new call once the previous load has completed. Calling multiple times in quick succession is not supported.
     
     - Parameters:
        - completion: A closure to be called on successful load or error.
        - result: The result of the page load request.
     */
    func loadNextPage(completion: @escaping (_ result: Result<ImagePage, NetworkError>) -> Void) {
        guard moreResultsAvailable else { return }
        // Need to check if this next request will overflow. If it will, adjust the page size.
        var pageSizeToRequest = self.preferredPageSize
        if let totalResults = self.totalResultsForCurrentSearchString, nextOffset + preferredPageSize > totalResults {
            pageSizeToRequest = totalResults - nextOffset
        }
        
        let filter = ImageQueryFilter(searchString: self.currentSearchString, animatedImagesOnly: self.filterSettings.animatedImagesOnly, facesOnly: self.filterSettings.facesOnly)
        
        self.provider.fetchImages(filter: filter, count: pageSizeToRequest, offset: self.nextOffset) { [weak self] result in
            guard let self = self else { return }
            
            if case .success(let page) = result {
            // Successful load, append data and update offsets.
                self.loadedMetadata.append(contentsOf: page.images)
                self.totalResultsForCurrentSearchString = page.totalEstimatedResults
                self.nextOffset = page.nextOffset
                
                if page.nextOffset == page.totalEstimatedResults {
                // We're at the end of the results. Time to pivot.
                    self.nextOffset = 0
                    self.totalResultsForCurrentSearchString = nil
                    
                    if let pivotString = page.suggestedPivotSearchString {
                        self.currentSearchString = pivotString
                    } else {
                        // No pivot string available! The game is up. Block further calls.
                        self.moreResultsAvailable = false
                    }
                }
            }
            
            completion(result)
        }
    }
}
