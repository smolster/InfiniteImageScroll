//
//  BingImageDataProvider.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/12/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// Our Microsoft API key.
private let API_KEY = "0cdda5825df44023a761a6a9306bce59"
/// Bing Image Search base URL.
private let BASE_URL = URL(string: "https://api.cognitive.microsoft.com/bing/v7.0/images/search")!

/// A `PagingImageDataProvider` that provides image metadata from the Bing Image Search API.
final class BingImageDataProvider: PagingImageDataProvider {
    
    /// Customized session.
    private let session: URLSession
    
    /// Customized decoder.
    private let decoder: JSONDecoder
    
    init() {
        session = URLSession(configuration: .default)
        
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.iso8601())
    }
    
    func fetchImages(filter: ImageQueryFilter, count: Int, offset: Int, completion: @escaping (_ result: Result<ImagePage, NetworkError>) -> Void) {
        var request = URLRequest(url: createURL(filter: filter, count: count, offset: offset))
        request.httpMethod = "GET"
        request.addValue(API_KEY, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        
        session.dataTask(with: request) { result in
            completion(result.flatMap(self.imagePage(fromData:)))
        }.resume()
    }
    
    // MARK: - Private Functions
    
    /**
     Attempts to decode `data` into an `ImagePage`.
     
     The only `NetworkError` case this function can return is `NetworkError.decodingError`. However, the return value's `Failure` type is set to `NetworkError` for convenience.
     
     - parameter data: The `Data` to be decoded.
     */
    private func imagePage(fromData data: Data) -> Result<ImagePage, NetworkError> {
        do {
            let apiResponse = try self.decoder.decode(APIResponse.self, from: data)
            
            let imageSet = ImagePage(
                totalEstimatedResults: apiResponse.totalEstimatedMatches,
                imageCount: apiResponse.value.count,
                nextOffset: apiResponse.nextOffset,
                images: apiResponse.value.map { $0.toLocalModel() },
                suggestedPivotSearchString: apiResponse.pivotSuggestions?.first?.suggestions.first?.text
            )
            
            return .success(imageSet)
        } catch let error {
            Logger.error("Error decoding APIResponse: \(error)")
            return .failure(.decodingError(error))
        }
    }
    
    /// Creates a URL using the provided parameters.
    private func createURL(filter: ImageQueryFilter, count: Int, offset: Int) -> URL {
        var components = URLComponents(url: BASE_URL, resolvingAgainstBaseURL: false)!
        
        components.queryItems = [
            .init(name: "q", value: filter.searchString),
            .init(name: "count", value: "\(count)"),
            .init(name: "offset", value: "\(offset)"),
            .init(name: "mkt", value: "en-US"),
            .init(name: "safeSearch", value: "Moderate")
        ]
        
        if filter.animatedImagesOnly {
            components.queryItems!.append(.init(name: "imageType", value: "AnimatedGif"))
        }
        
        if filter.facesOnly {
            components.queryItems!.append(.init(name: "imageContent", value: "Face"))
        }
        
        return components.url!
    }
    
}

// MARK: - Private API-related structs

/// Represents the highest-level JSON object returned from Microsoft API.
private struct APIResponse: Decodable {
    
    let value: [Image]
    let totalEstimatedMatches: Int
    let nextOffset: Int
    let currentOffset: Int
    let pivotSuggestions: [SuggestionsDict]?
    
    struct Image: Decodable {
        let name: String
        let thumbnailUrl: URL
        let contentUrl: URL
    }
    
    struct SuggestionsDict: Decodable {
        struct Suggestion: Decodable {
            let text: String
        }
        let suggestions: [Suggestion]
    }
}

extension APIResponse.Image {
    /// Converts the receiver into our local `ImageMetadata` model.
    func toLocalModel() -> ImageMetadata {
        return ImageMetadata(name: self.name, thumbnailURL: self.thumbnailUrl, contentURL: self.contentUrl)
    }
}
