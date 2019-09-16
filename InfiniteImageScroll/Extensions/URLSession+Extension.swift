//
//  URLSession+Extension.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/13/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/*
 This extension codifies the true definition of the `URLSession.dataTask(with:completionHandler:)` API, as described in Apple Docs:
 
 From Apple Docs:
 - "If the request completes successfully, the data parameter of the completion handler block contains the resource data, and the error parameter is nil. If the request fails, the data parameter is nil and the error parameter contain information about the failure. If a response from the server is received, regardless of whether the request completes successfully or fails, the response parameter contains that information."
 */

extension URLSession {
    /**
     Creates a task that retrieves the contents of the specified URL, then calls a handler upon completion.
     
     This function wraps the Foundation-provided `dataTask(with:completionHandler` function into a clearer and more type-accurate API. See documentation on `dataTask(with:completionHandler` for a more in-depth description of the underlying functionality.
     
     - Parameters:
        - url: The URL to be retrieved.
        - completion: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
        - result: Either the requested `Data` from the provided `URL`, or a `NetworkError`.
     */
    func dataTask(with url: URL, completion: @escaping (_ result: Result<Data, NetworkError>) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else {
                /// According to API documentation, we know `error` is non-nil if data is `nil`, so safe to force cast.
                completion(.failure(.urlSessionError(error!, response)))
            }
        }
    }
    
    /**
     Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion.
     
     This function wraps the Foundation-provided `dataTask(with:completionHandler` function into a clearer and more type-accurate API. See documentation on `dataTask(with:completionHandler` for a more in-depth description of the underlying functionality.
     
     - Parameters:
        - request: A URL request object that provides the URL, cache policy, request type, body data or body stream, and so on.
        - completion: The completion handler to call when the load request is complete. This handler is executed on the delegate queue.
        - result: Either the requested `Data` from the provided `URL`, or a `NetworkError`.
     */
    func dataTask(with request: URLRequest, completion: @escaping (_ result: Result<Data, NetworkError>) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: request) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else {
                /// According to API documentation, we know `error` is non-nil if data is `nil`, so safe to force cast.
                completion(.failure(.urlSessionError(error!, response)))
            }
        }
    }
}
