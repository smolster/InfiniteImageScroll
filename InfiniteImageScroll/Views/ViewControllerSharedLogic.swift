//
//  ViewControllerSharedLogic.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

/**
 Returns a closure that takes an increment parameter, and inserts as many items at the end of a `UICollectionViewController`'s collection view.
 
 Using this function in collection views with multiple sections is not supported.
 
 - Important: The property keyed by `backingModelKeyPath` should be the sole determiner of the number of items in the collection view. In the example below, `backingModelKeyPath` would correspond to `\MyViewController.totalCellCount`.
 
    ```
     class MyViewController: UICollectionViewController {
        private var totalCellCount: Int = 0
        ...
        // MARK: - UICollectionViewDataSource
        override func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
 
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.totalCellCount
        }
        ...
     }
    ```
 
 - Parameters:
    - collectionViewController: The collection view controller to update.
    - backingModelKeyPath: A writable key path to an integer stored on `collectionViewController` that determines the number of items in its collection view.
 */
func incrementItemsInSingleSectionCollectionView<T>(_ collectionViewController: T, backingModelKeyPath: WritableKeyPath<T, Int>) -> OutputFunction<Int> where T: UICollectionViewController {
    return { [weak collectionViewController] increment in
        guard var collectionViewController = collectionViewController else { return }
        dispatchToMainIfNeeded {
            let oldNumberOfItems = collectionViewController[keyPath: backingModelKeyPath]
            let newIndexPaths = (oldNumberOfItems..<oldNumberOfItems+increment).map { IndexPath(row: $0, section: 0) }
            collectionViewController[keyPath: backingModelKeyPath] += increment
            collectionViewController.collectionView.insertItems(at: newIndexPaths)
        }
    }
}
