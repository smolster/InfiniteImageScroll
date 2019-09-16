//
//  SettingsTableViewCell.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/15/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

final class SettingsTableViewCell: UITableViewCell {
    
    /// Enumerates the different available cell configurations.
    enum Configuration {
        /// Text on left, toggle on right intially displaying `initialValue`. Switching the toggle makes a call to the provided `toggleChanged` closure, passing the new `isOn` value.
        case toggle(leftText: String, initialValue: Bool, toggleChanged: (Bool) -> Void)
        
        /// Text on left, text field on right initially displaying `initialValue`. Editing the text field makes a call tothe provided callback, passing the new string.
        case textField(leftText: String, initialValue: String, textChanged: (String) -> Void)
    }
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var textField: UITextField! {
        didSet { textField.delegate = self }
    }
    @IBOutlet weak var toggle: UISwitch! {
        didSet { toggle.addTarget(self, action: #selector(toggleValueChanged(_:)), for: .valueChanged) }
    }
    
    private var toggleChangedCallback: ((Bool) -> Void)?
    private var textChangedCallback: ((String) -> Void)?
    
    /// Configures the cell with the provided `configuration`.
    func configure(as configuration: Configuration) {
        switch configuration {
        case .toggle(leftText: let leftText, initialValue: let initialValue, toggleChanged: let toggleChangedCallback):
            self.textField.isHidden = true
            self.textChangedCallback = nil
            self.leftLabel.text = leftText
            self.toggle.isOn = initialValue
            self.toggleChangedCallback = toggleChangedCallback
        case .textField(leftText: let leftText, initialValue: let initialValue, textChanged: let textChangedCallback):
            self.toggle.isHidden = true
            self.toggleChangedCallback = nil
            self.leftLabel.text = leftText
            self.textField.text = initialValue
            self.textChangedCallback = textChangedCallback
        }
    }
    
    // MARK: Selector Methods
    @objc private func toggleValueChanged(_ toggle: UISwitch) {
        self.toggleChangedCallback?(toggle.isOn)
    }
}

extension SettingsTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textChangedCallback?(self.textField.text ?? "")
        self.textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.textChangedCallback?(self.textField.text ?? "")
        self.textField.resignFirstResponder()
    }
    
}

extension SettingsTableViewCell: Reusable, NibLoadable {
    static var reuseIdentifier: String { return "SettingsTableViewCell" }
    static var nibName: String { return "SettingsTableViewCell" }
}
