//
//  NetworkError.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// Enumerates network-related errors.
enum NetworkError: Error {
    
    /// An error was encountered during decoding.
    case decodingError(Error)
    /// An error was encountered during actual networking.
    case urlSessionError(Error, URLResponse?)
    
    /// A code for identifying errors.
    var code: String {
        switch self {
        case .decodingError(let error as NSError):
            return "DEC-\(error.domain)-\(error.code)"
        case .urlSessionError(let error as NSError, let response):
            if let httpResponse = response as? HTTPURLResponse {
                return "URL-Status-\(httpResponse.statusCode)"
            } else {
                return "URL-\(error.domain)-\(error.code)"
            }
        }
    }
}
