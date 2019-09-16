//
//  UserSettings.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/15/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// Encapsulates the user's settings.
struct UserSettings: Equatable {
    /// Search string used for fetching images.
    var searchString: String
    
    /// Indicates if "GIF Mode" is on.
    var gifModeOn: Bool
    
    /// Indicates if "Face Mode" is on.
    var faceModeOn: Bool
    
    /// The default settings.
    static var `default`: UserSettings {
        return .init(searchString: "NASA", gifModeOn: false, faceModeOn: false)
    }
}
