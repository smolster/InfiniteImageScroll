//
//  ThreadSafeDictionary.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// A thread-safe dictionary box, with access to underlying elements available through standard subscripting.
final class ThreadSafeDictionary<Key: Hashable, Value> {
    /// Private queue.
    private var queue: DispatchQueue!
    
    /// Underlying elements.
    private var dictionary: [Key: Value]
    
    init(initialElements: [Key: Value] = [:], qos: DispatchQoS = .default) {
        self.dictionary = initialElements
        self.queue = DispatchQueue(label: "ThreadSafeDictionary.\(ObjectIdentifier(self).debugDescription)", qos: qos)
    }
    
    subscript(key: Key) -> Value? {
        get {
            return queue.sync {
                return dictionary[key]
            }
        }
        set (newValue) {
            queue.async {
                self.dictionary[key] = newValue
            }
        }
    }
}
