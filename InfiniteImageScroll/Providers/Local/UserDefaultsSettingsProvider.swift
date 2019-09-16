//
//  UserDefaultsSettingsProvider.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/15/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

/// A `UserSettingsProvider` that uses `UserDefaults` to store settings.
final class UserDefaultsSettingsProvider: UserSettingsProvider {
    
    /// Our `UserDefaults` object.
    private let userDefaults: UserDefaults
    
    // Keys for individual settings.
    private let searchStringKey = "settingsSearchString"
    private let gifModeKey = "settingsGIFMode"
    private let faceModeKey = "settingsFaceMode"
    
    /**
     Creates a new receiver that uses the provided `UserDefaults` for storage and retrieval. Default is `UserDefaults.standard`.
     
     - parameter userDefaults: The `UserDefaults` to use for storing and retrieving settings.
     */
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func updateStoredSettings(to newSettings: UserSettings) {
        self.userDefaults.set(newSettings.gifModeOn, forKey: gifModeKey)
        self.userDefaults.set(newSettings.faceModeOn, forKey: faceModeKey)
        self.userDefaults.set(newSettings.searchString, forKey: searchStringKey)
    }
    
    func retrieveStoredSettings() -> UserSettings {
        let gifModeSetting = (self.userDefaults.value(forKey: gifModeKey) as? Bool) ?? UserSettings.default.gifModeOn
        let faceModeSetting = (self.userDefaults.value(forKey: faceModeKey) as? Bool) ?? UserSettings.default.faceModeOn
        let searchString = self.userDefaults.string(forKey: searchStringKey) ?? UserSettings.default.searchString
        return UserSettings(searchString: searchString, gifModeOn: gifModeSetting, faceModeOn: faceModeSetting)
    }
    
}
