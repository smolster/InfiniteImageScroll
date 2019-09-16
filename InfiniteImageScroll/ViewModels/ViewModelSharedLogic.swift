//
//  ViewModelSharedLogic.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/**
 Returns a UserAlert for an image data load network error, displaying a user-friendly message, an OK button, and a Retry button.
 
 - Parameters:
    - networkError: The error that occurred.
    - okAction: An action for the OK button.
    - retryAction: An action for the Retry button.
 */
func imageDataNetworkErrorAlert(networkError: NetworkError, okAction: (() -> Void)?, retryAction: @escaping () -> Void) -> UserAlert {
    return UserAlert(
        title: "Network Error",
        message: "We encountered an issue trying to load image data.\nCode: \(networkError.code)",
        options: [
            .ok(action: okAction),
            .custom(text: "Retry", destructive: false, action: retryAction)
        ]
    )
}
