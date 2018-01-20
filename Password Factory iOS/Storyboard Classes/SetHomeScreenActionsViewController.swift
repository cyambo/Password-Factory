//
//  SetHomeScreenActionsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 1/4/18.
//  Copyright © 2018 Cristiana Yambo. All rights reserved.
//

import UIKit

class SetHomeScreenActionsViewController: UITableViewController {
    var enabledItems = [PFPasswordType]()
    var disabledItems = [PFPasswordType]()
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    let passwordController = PasswordController.get()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.title = "Shortcuts"
        setupItems()
    }

    /// Saves the shortcut items to defaults
    func saveItems() {
        //make arrays of just the rawValue, rather than the type
        let enabled = enabledItems.map{ $0.rawValue }
        let disabled = disabledItems.map{ $0.rawValue }
        d.setObject(enabled, forKey: "enabledHomeScreenItems")
        d.setObject(disabled, forKey: "disabledHomeScreenItems")
        //update the shortcuts
        Utilities.setHomeScreenActions()
    }
    
    /// Loads the items from defaults and sets up the data source
    func setupItems() {
        guard let enabled = d.object(forKey: "enabledHomeScreenItems") as? [Int] else { return }
        guard let disabled = d.object(forKey: "disabledHomeScreenItems") as? [Int] else { return }
        enabledItems = enabled.map {
            PFPasswordType.init(rawValue: $0) ?? .randomType
        }
        
        disabledItems  = disabled.map {
            PFPasswordType.init(rawValue: $0) ?? .randomType
        }
        //if advanced is not enabled and advanced is in the enabled items, move it to disabled
        if !d.bool(forKey: "enableAdvanced") && enabledItems.contains(.advancedType) {
            enabledItems = enabledItems.filter { $0 != .advancedType }
            disabledItems.append(.advancedType)
        }
    }
    
    /// Gets the password type for the index path
    ///
    /// - Parameter indexPath: path to get type
    /// - Returns: password type
    func getPasswordTypeFor(indexPath: IndexPath) -> (PFPasswordType, Bool) {
        let curr: [PFPasswordType]
        var enabled = false
        //if it is in section 0 it is enabled
        if indexPath.section == 0 {
            curr = enabledItems
            enabled = true
        //otherwise it is disabled
        } else {
            curr = disabledItems
            enabled = false
        }
        //for some reason if the index is past the end, return random
        if indexPath.row > curr.count {
            return (.randomType, enabled)
        //otherwise return the value
        } else {
            return (curr[indexPath.row], enabled)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ActionCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //table is always in edit mode
        isEditing = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return enabledItems.count
        } else {
            return disabledItems.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCell =  tableView.dequeueReusableCell(withIdentifier: "ActionCell", for: indexPath)

        let iconColor = PFConstants.tintColor
        let (passwordType, _) = getPasswordTypeFor(indexPath: indexPath)

        currentCell.textLabel?.text = c.getNameFor(type: passwordType)
        currentCell.imageView?.image = TypeIcons.getTypeIcon(type: passwordType, andColor: iconColor)
        currentCell.tag = passwordType.rawValue
        return currentCell
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //get the type of source
        let (passwordType, fromEnabled) = getPasswordTypeFor(indexPath: sourceIndexPath)
        if sourceIndexPath == destinationIndexPath { return }

        var toEnabled = false
        if destinationIndexPath.section == 0 {
            toEnabled = true
        }
        var toData = enabledItems
        var fromData = disabledItems
        //are we moving from different sections
        if fromEnabled != toEnabled {
            if toEnabled == false {
                toData = disabledItems
                fromData = enabledItems
            }
            fromData.remove(at: sourceIndexPath.row)
            toData.insert(passwordType, at: destinationIndexPath.row)
            if toEnabled {
                enabledItems = toData
                disabledItems = fromData
            } else {
                enabledItems = fromData
                disabledItems = toData
            }
        //otherwise it is moving from same section
        } else {
            var data = enabledItems
            if toEnabled == false {
                data = disabledItems
            }
            data.remove(at: sourceIndexPath.row)
            data.insert(passwordType, at: destinationIndexPath.row)
            
            if toEnabled {
                enabledItems = data
            } else {
                disabledItems = data
            }
        }
        //if we have too many enabled items, moved the last one to disabled
        if enabledItems.count > 4 {
            guard let removedType = enabledItems.last else { return }

            enabledItems.removeLast()
            disabledItems.insert(removedType, at: 0)
            
            tableView.beginUpdates()
            tableView.moveRow(at: IndexPath.init(row: 3, section: 0), to: IndexPath.init(row: 0, section: 1))
            tableView.endUpdates()

        }
        saveItems()
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let (passwordType, _) = getPasswordTypeFor(indexPath: indexPath)
        //advanced cannot be moved from disabled if it is disabled
        if passwordType == .advancedType && !d.bool(forKey: "enableAdvanced") {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderLabel()
        if section == 0 {
            header.text = "Enabled (Max 4)"
        } else {
            header.text = "Disabled"
        }
        return header
    }
}
