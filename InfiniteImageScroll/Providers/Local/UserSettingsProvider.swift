//
//  UserSettingsProvider.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/15/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// An object that can be used to store and retrieve `UserSettings`.
protocol UserSettingsProvider {
    /**
     Synchronously updates the stored settings to a new value.
     
     - parameter newSettings: The new `UserSettings` to store.
     */
    func updateStoredSettings(to newSettings: UserSettings)
    
    /// Returns previously stored settings, or `UserSettings.default` if no settings were found.
    func retrieveStoredSettings() -> UserSettings
}
