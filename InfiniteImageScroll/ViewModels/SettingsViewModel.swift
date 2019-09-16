//
//  SettingsViewModel.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/15/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import Foundation

protocol SettingsViewModelInputs: class {
    /// Call at the end of viewDidLoad.
    func viewDidLoad()
    
    /// Call when the user changes the state of the GIF Mode toggle, providing the new state.
    func userSwitchedGIFModeToggle(isOn: Bool)
    
    /// Call when the user changes the state of the Face Mode toggle, providing the new state.
    func userSwitchedFaceModeToggle(isOn: Bool)
    
    /// Call when the user updates the text of the search string.
    func userUpdatedSearchStringText(to newText: String)
    
    /// Call when the user taps the "Done" button.
    func userTappedDoneButton()
}

protocol SettingsViewModelOutputs: class {
    /// Outputs when the provided setting should be displayed.
    var displaySettings: OutputFunction<UserSettings>? { get set }
    
    /// Outputs when the screen should be dismissed.
    var dismiss: OutputFunction<Void>? { get set }
}

protocol SettingsViewModelType: class {
    var inputs: SettingsViewModelInputs { get }
    var outputs: SettingsViewModelOutputs { get }
}

final class SettingsViewModel: SettingsViewModelInputs, SettingsViewModelOutputs, SettingsViewModelType {
    
    /// Our `UserSettingsProvider`.
    private let provider: UserSettingsProvider
    
    /// Initial settings on entry to the screen.
    private var initialSettings: UserSettings!
    
    /// Current "new" settings.
    private var currentSettings: UserSettings!
    
    init(settingsProvider: UserSettingsProvider) {
        self.provider = settingsProvider
    }
    
    var inputs: SettingsViewModelInputs { return self }
    var outputs: SettingsViewModelOutputs { return self }
    
    // MARK: - Outputs
    var displaySettings: OutputFunction<UserSettings>?
    var dismiss: OutputFunction<Void>?
    
    // MARK: - Inputs
    
    func viewDidLoad() {
        self.initialSettings = provider.retrieveStoredSettings()
        self.currentSettings = initialSettings
        self.outputs.displaySettings?(currentSettings)
    }
    
    func userSwitchedGIFModeToggle(isOn: Bool) {
        self.currentSettings.gifModeOn = isOn
    }
    
    func userSwitchedFaceModeToggle(isOn: Bool) {
        self.currentSettings.faceModeOn = isOn
    }
    
    func userUpdatedSearchStringText(to newText: String) {
        // Don't allow empty string.
        guard newText != "" else {
            self.currentSettings.searchString = UserSettings.default.searchString
            self.displaySettings?(currentSettings)
            return
        }
        self.currentSettings.searchString = newText
    }
    
    func userTappedDoneButton() {
        self.provider.updateStoredSettings(to: currentSettings)
        self.outputs.dismiss?(())
    }
}

