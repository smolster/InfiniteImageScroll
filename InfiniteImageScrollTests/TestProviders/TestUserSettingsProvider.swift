//
//  TestUserSettingsProvider.swift
//  InfiniteImageScrollTests
//
//  Created by Swain Molster on 9/16/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation
@testable import InfiniteImageScroll

/// A `UserSettingsProvider` that can be used for testing. Maintains an in-memory cache to optionally simulate storage.
final class TestUserSettingsProvider: UserSettingsProvider {
    
    private let update: (UserSettings, _ store: (UserSettings) -> Void) -> Void
    private let retrieve: (_ storedSetting: UserSettings) -> UserSettings
    
    /// In-memory cache for simulating storage.
    private var storedSettings: UserSettings = .default
    
    /**
     Creates a new receiver with the provided parameters
     
     - parameter update: A closure that will called on every call to `updateStoredSettings(newSettings:)`.
     - parameter newSettings: The new settings passed to `updateStoredSettings(newSettings:)`.
     - parameter store: A function that can be used to store settings into the in-memory cache.
     - parameter settingsToStore: The settings to store.
     - parameter retrieve: A closure that will be used to fulfill calls to `retrieveStoredSettings()`.
     - parameter storedSettings: The current settings stored in the in-memory cache.
     */
    init(
        update: @escaping (_ newSettings: UserSettings, _ store: (_ settingsToStore: UserSettings) -> Void) -> Void,
        retrieve: @escaping (_ storedSettings: UserSettings) -> UserSettings) {
        self.update = update
        self.retrieve = retrieve
    }
    
    func updateStoredSettings(to newSettings: UserSettings) {
        update(newSettings) { setting in
            self.storedSettings = setting
        }
    }
    
    func retrieveStoredSettings() -> UserSettings {
        return retrieve(self.storedSettings)
    }
    
    /// Returns an instance of the receiver that acts as a perfect `UserSettingsProvider` through the use of an in-memory cache .
    static func alwaysSuccess() -> TestUserSettingsProvider {
        return .init(update: { newSettings, storeSettings in
            storeSettings(newSettings)
        }, retrieve: { storedSetting in
            return storedSetting
        })
    }
}
