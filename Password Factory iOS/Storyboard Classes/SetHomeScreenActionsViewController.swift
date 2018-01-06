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
    let passwordController = PasswordController.get(false)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.title = "Shortcuts"
        setupItems()
        
    }

    func saveItems() {
        let enabled = enabledItems.map{ $0.rawValue }
        let disabled = disabledItems.map{ $0.rawValue }
        d.setObject(enabled, forKey: "enabledHomeScreenItems")
        d.setObject(disabled, forKey: "disabledHomeScreenItems")
        Utilities.setHomeScreenActions()
    }
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
    func getPasswordTypeFor(indexPath: IndexPath) -> (PFPasswordType, Bool) {
        let curr: [PFPasswordType]
        var enabled = false
        if indexPath.section == 0 {
            curr = enabledItems
            enabled = true

        } else {
            curr = disabledItems
            enabled = false
        }
        if indexPath.row > curr.count {
            return (.randomType, enabled)
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
        let (passwordType, fromEnabled) = getPasswordTypeFor(indexPath: sourceIndexPath)
        if sourceIndexPath == destinationIndexPath { return }

        var toEnabled = false
        if destinationIndexPath.section == 0 {
            toEnabled = true
        }
        var toData = enabledItems
        var fromData = disabledItems
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
            tableView.reloadData()
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
