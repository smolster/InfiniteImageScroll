//
//  SettingsViewController.swift
//  InfiniteImageScroll
//
//  Created by Swain Molster on 9/15/19.
//  Copyright © 2019 Swain Molster. All rights reserved.
//

import UIKit

final class SettingsViewController: UITableViewController {
    
    private let viewModel: SettingsViewModelType
    
    private var currentlyDisplayedSettings: UserSettings?
    
    init(viewModel: SettingsViewModelType) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.tableView.allowsSelection = false
        self.tableView.registerNib(for: SettingsTableViewCell.self)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonPressed(_:)))
        
        self.viewModel.outputs.displaySettings = { [weak self] settings in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                self.currentlyDisplayedSettings = settings
                self.tableView.reloadData()
            }
        }
        
        self.viewModel.outputs.dismiss = { [weak self] _ in
            guard let self = self else { return }
            dispatchToMainIfNeeded {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.viewModel.inputs.viewDidLoad()
    }
    
    // MARK: - Selector Methods
    @objc private func doneButtonPressed(_ button: UIBarButtonItem) {
        self.viewModel.inputs.userTappedDoneButton()
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 3 if we have settings, 0 if we don't.
        return currentlyDisplayedSettings == nil ? 0 : 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SettingsTableViewCell.self, for: indexPath)
        
        switch indexPath.row {
        case 0: // GIF Mode row.
            cell.configure(as: .toggle(
                leftText: "GIF Mode",
                initialValue: currentlyDisplayedSettings!.gifModeOn,
                toggleChanged: { [weak self] newValue in
                    self?.currentlyDisplayedSettings!.gifModeOn = newValue
                    self?.viewModel.inputs.userSwitchedGIFModeToggle(isOn: newValue)
                }
            ))
        case 1: // Face Mode row.
            cell.configure(as: .toggle(
                leftText: "Face Mode",
                initialValue: currentlyDisplayedSettings!.faceModeOn,
                toggleChanged: { [weak self] newValue in
                    self?.currentlyDisplayedSettings!.faceModeOn = newValue
                    self?.viewModel.inputs.userSwitchedFaceModeToggle(isOn: newValue)
                }
            ))
        case 2: // Search string row.
            cell.configure(as: .textField(
                leftText: "Search String",
                initialValue: currentlyDisplayedSettings!.searchString,
                textChanged: { [weak self] newString in
                    self?.currentlyDisplayedSettings!.searchString = newString
                    self?.viewModel.inputs.userUpdatedSearchStringText(to: newString)
                }
            ))
        default: fatalError()
        }
        return cell
    }
}
