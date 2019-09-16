//
//  UICollectionViewLayout+Extension.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

extension UICollectionViewLayout {
    /**
     Returns a collection view flow layout for a regular grid.
     
     - Note: This layout does not suppport collection views with variable widths.
     
     - Parameters:
        - totalWidth: The total width of the collectionView.
        - itemsPerRow: The desired number of items displayed on each row.
        - spacing: The desired spacing between items.
     */
    static func regularGrid(totalWidth: CGFloat, itemsPerRow: Int, spacing: CGFloat) -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = spacing
        flowLayout.minimumInteritemSpacing = spacing
        
        let widthMinusSpacers = totalWidth - ((itemsPerRow.cgFloat-1.0) * spacing)
        let itemWidth = widthMinusSpacers / itemsPerRow.cgFloat
        
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        return flowLayout
    }
}

// This helps in visually understand the math above.
private extension Int {
    var cgFloat: CGFloat { return CGFloat(self) }
}
