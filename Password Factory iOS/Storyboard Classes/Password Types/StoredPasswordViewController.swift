//
//  StoredPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class StoredPasswordViewController: PasswordsViewController, UITableViewDelegate, UITableViewDataSource{
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

    override func viewDidLoad() {
        super.viewDidLoad()
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
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        ascending = true
        changeSort(.Time)
        //when view appears, select the first password when generating
        selectFirstPassword = true
    }
    override func generatePassword() -> String {
        var index  = 0
        if !selectFirstPassword {
            index = Int(SecureRandom.randomInt(uint(s.count())))
        }
        selectFirstPassword = false
        selectPasswordAtIndex(index)
        d.setObject(index, forKey: "storedPasswordTableSelectedRow")
        return super.generatePassword()
        
    }
    func selectPasswordAtIndex(_ index: Int){

        if index > Int(s.count()) - 1 {
            return
        }
        DispatchQueue.main.async {
           self.storedPasswordsTable.selectRow(at: IndexPath.init(row: Int(index), section: 0), animated: true, scrollPosition: .top)
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            typeSelectionViewController?.updatePasswordField(p, strength: s)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            s.deleteItem(at: UInt(indexPath.row))
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(s.count())
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 36
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
