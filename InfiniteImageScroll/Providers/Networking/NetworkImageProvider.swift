//
//  CachingImageProvider.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
import UIKit

/// An `ImageProvider` that always fetches images from the network (no caching).
final class NetworkImageProvider: ImageProvider {
    
    /// Our customized `URLSession`.
    private let session: URLSession = .init(configuration: .default)
    
    /// Tracks the currently ongoing load tasks.
    private var ongoingTasks = ThreadSafeDictionary<URL, URLSessionDataTask>()
    
    /// Our in-memory cache.
    private let memoryCache: ImageMemoryCache<URL>
    
    init(maxNumberCachedImages: Int = 50, cacheQoS: DispatchQoS = .userInitiated) {
        self.memoryCache = .init(maxImages: maxNumberCachedImages, qos: cacheQoS)
    }
    
    func fetchImage(at url: URL, then completion: @escaping (Result<VisualImage, NetworkError>) -> Void) {
        
        let task = session.dataTask(with: url) { result in
            // Task is complete, so remove from ongoing tasks.
            self.ongoingTasks[url] = nil
            
            let newResult = result.flatMap(self.visualImage(fromData:))
            
            if case .success(let image) = newResult {
                self.memoryCache.store(visualImage: image, forKey: url)
            }
            
            // Call completion.
            completion(newResult)
        }
        
        // Store in ongoing tasks.
        ongoingTasks[url] = task
        
        // Kick off request.
        task.resume()
    }
    
    func cancelImageLoad(from url: URL) {
        ongoingTasks[url]?.cancel()
    }
    
    // MARK: - Private Functions
    
    private func visualImage(fromData data: Data) -> Result<VisualImage, NetworkError> {
        if let visualImage = VisualImage(data: data) {
            return .success(visualImage)
        } else {
            return .failure(.decodingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Bad image data. Couldn't create VisualImage."))))
        }
    }
    
}

/// A basic in-memory image cache.
private final class ImageMemoryCache<Key: Hashable> {
    
    /// Private queue.
    private let queue: DispatchQueue
    
    private let maxImages: Int
    private let imageDictionary: ThreadSafeDictionary<Key, Data>
    private var imagesContained: Int = 0
    private var keysInserted: [Key] = []
    
    init(maxImages: Int, qos: DispatchQoS = .userInitiated) {
        self.queue = DispatchQueue(label: "ImageCache", qos: qos)
        self.imageDictionary = ThreadSafeDictionary(qos: qos)
        self.maxImages = maxImages
    }
    
    func store(visualImage: VisualImage, forKey key: Key) {
        queue.async {
            let imageData: Data?
            switch visualImage {
            case .still(let stillImage): imageData = stillImage.pngData()
            case .animated(let animatedImage): imageData = animatedImage.data
            }
            
            guard let data = imageData else { return }
            
            self.imageDictionary[key] = data
            self.keysInserted.append(key)
            self.imagesContained += 1
            
            if self.imagesContained > self.maxImages {
                let oldestKey = self.keysInserted.remove(at: 0)
                self.imageDictionary[oldestKey] = nil
                self.imagesContained -= 1
            }
        }
    }
    
    func image(forKey key: Key) -> VisualImage? {
        return queue.sync {
            guard let imageData = imageDictionary[key] else { return nil }
            
            guard let image = VisualImage(data: imageData) else {
                // Bad image data was stored, clear it from the cache.
                imageDictionary[key] = nil
                return nil
            }
            
            return image
        }
    }
}
