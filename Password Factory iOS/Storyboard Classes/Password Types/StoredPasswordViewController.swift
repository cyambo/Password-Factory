//
//  StoredPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class StoredPasswordViewController: PasswordsViewController, UITableViewDelegate, UITableViewDataSource, DefaultsManagerDelegate, PasswordStorageDelegate{

    let s = PasswordStorage.get()!
    enum SortTypes : Int {
        case PasswordType = 9901
        case Password
        case Strength
        case Length
        case Time
    }
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var lengthButton: UIButton!
    @IBOutlet weak var strengthButton: UIButton!
    @IBOutlet weak var storedPasswordsTable: UITableView!
    var sortButtons : [SortTypes: UIButton] = [:]
    var selectFirstPassword = true
    var sortedBy : SortTypes = .Time
    var ascending = false

    override func awakeFromNib() {
        d.observeDefaults(self, keys: ["maxStoredPasswords", "storePasswords", "colorPasswordText", "upperTextColor", "lowerTextColor", "symbolTextColor", "defaultTextColor", "cloudKitZoneStartTime"])
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        s.delegate = self
        sortButtons = [
            .PasswordType : typeButton,
            .Password : passwordButton,
            .Strength : strengthButton,
            .Length : lengthButton
        ]
        for (sort,button) in sortButtons {
            button.setTitle("", for: .normal)
            button.setImage(getImageForSort(sort), for: .normal)
        }
    }
    
    @IBAction func clickedSortButton(_ sender: UIButton) {
        if let sort = SortTypes.init(rawValue: sender.tag) {
            changeSort(sort)
        }
    }
    func receivedUpdatedData() {
        let range = NSRange.init(location: 0, length: 1)
        let sections = NSIndexSet.init(indexesIn: range)
        self.storedPasswordsTable.reloadSections(sections as IndexSet, with: .automatic)
    }
    func changeSort(_ toSort: SortTypes) {
        if sortedBy != toSort {
            let oldSort = sortedBy
            sortedBy = toSort
            ascending = false
            if let sb = sortButtons[oldSort] {
                sb.setImage(getImageForSort(oldSort), for: .normal)
            }

        } else {
            ascending = !ascending
        }
        if let sb = sortButtons[sortedBy] {
            sb.setImage(getImageForSort(sortedBy), for: .normal)
        }
        let sortName = getNameForSort(sortedBy)
        let sort = NSSortDescriptor.init(key: sortName, ascending: ascending)
        s.setSortDescriptor(sort)
        storedPasswordsTable.reloadData()
        if storedPasswordsTable.numberOfSections > 0 && storedPasswordsTable.numberOfRows(inSection: 0) > 0 {
            storedPasswordsTable.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        
    }
    func getImageForSort(_ sort : SortTypes) -> UIImage {
        let baseImage: UIImage
        switch sort {
        case .Length:
            baseImage = StyleKit.imageOfPasswordLengthHeader
        case .Password:
            baseImage = StyleKit.imageOfPasswordHeader
        case .PasswordType:
            baseImage = StyleKit.imageOfPasswordTypeHeader
        case .Strength:
            baseImage = StyleKit.imageOfPasswordStrengthHeader
        case .Time:
            baseImage = UIImage()
        }
        if sortedBy == sort {
            let arrow : UIImage
            if ascending {
                arrow = StyleKit.imageOfHeaderUpArrow
            } else {
                arrow = StyleKit.imageOfHeaderDownArrow
            }
            return baseImage.combine(arrow)
        }
        return baseImage
    }
    func getNameForSort(_ sort: SortTypes) -> String {
        switch sort {
        case .Length:
            return "length"
        case .Password:
            return "password"
        case .PasswordType:
            return "type"
        case .Strength:
            return "strength"
        case .Time:
            return "time"
        }
    }

    func observeValue(_ keyPath: String?, change: [AnyHashable : Any]?) {
        if keyPath == "maxStoredPasswords" || keyPath == "storePasswords" {
            s.changedMaxStorageAmount()
        }
        storedPasswordsTable.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ascending = true
        changeSort(.Time)
        //when view appears, select the first password when generating
        selectFirstPassword = true
        
    }
    override func updateStrength(withCrackTime: Bool) {
        //load the currently selected password
        let selectedIndex = d.integer(forKey: "storedPasswordTableSelectedRow")
        guard let p = s.password(at: UInt(selectedIndex)) else { return }
        currentPassword = p.password ?? ""
        //and set it
        controller?.password = currentPassword
        //so the crack time can be properly generated
        super.updateStrength(withCrackTime: withCrackTime)
        
    }
    override func generatePassword() -> String {
        var index  = 0
        if !selectFirstPassword {
            index = Int(SecureRandom.randomInt(uint(s.count())))
        }
        selectFirstPassword = false
        selectPasswordAtIndex(index)
        d.setObject(index, forKey: "storedPasswordTableSelectedRow")
        var password = ""
        //run on the main queue because coredata needs to be on the main queue
        DispatchQueue.main.sync {
            password = super.generatePassword()
        }
        return password
        
    }
    func selectPasswordAtIndex(_ index: Int){
        if index > Int(s.count()) - 1 { return }
        if s.count() <= 0 { return }
        DispatchQueue.main.async {
            let indexPath = IndexPath.init(row: Int(index), section: 0)
            self.storedPasswordsTable.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        d.setObject(indexPath.row, forKey: "storedPasswordTableSelectedRow")
        if let cell = storedPasswordsTable.cellForRow(at: indexPath) as? StoredPasswordTableViewCell {
            guard let p = cell.password.text else {
                return
            }
            guard let st = cell.strength.text else {
                return
            }
            guard let s = Double(st) else {
                return
            }
            var ct = ""
            if let c = controller {
                if d.bool(forKey: "displayCrackTime") {
                    ct = c.getCrackTime(p)
                }
            }
            
            typeSelectionViewController?.updatePasswordField(p, strength: s, crackTime: ct)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            s.deleteItem(at: UInt(indexPath.row), complete: {
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            });
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let c = s.count()
        let max = d.integer(forKey: "maxStoredPasswords")
        if c > max {
            return max
        } else {
            return Int(c)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let p = s.password(at: UInt(indexPath.row)) else {
            return StoredPasswordTableViewCell()
        }
        var currentCell: StoredPasswordTableViewCell!
        if let cell =  tableView.dequeueReusableCell(withIdentifier: "PasswordCell", for: indexPath) as? StoredPasswordTableViewCell {
            currentCell = cell
        } else {
            currentCell = StoredPasswordTableViewCell()
        }
        currentCell.setupCell(p)
        currentCell.layoutMargins = UIEdgeInsets.zero
        return currentCell
    }
    
}

