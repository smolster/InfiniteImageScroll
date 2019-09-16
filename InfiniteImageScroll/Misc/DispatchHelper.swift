//
//  DispatchHelper.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/**
 Dispatches a `block` to the main thread asynchronously, or executes it immediately (synchronously) if already on the main thread.
 
 - parameter block: The closure to execute.
 */
func dispatchToMainIfNeeded(block: @escaping () -> Void) {
    if Thread.current.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}
