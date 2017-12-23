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
    
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var lengthButton: UIButton!
    @IBOutlet weak var strengthButton: UIButton!
    @IBOutlet weak var storedPasswordsTable: UITableView!
    
    var selectFirstPassword = true
    var sortedBy = ""
    var ascending = false
    override func viewDidLoad() {
        super.viewDidLoad()
        typeButton.setTitle("", for: .normal)
        passwordButton.setTitle("", for: .normal)
        strengthButton.setTitle("", for: .normal)
        lengthButton.setTitle("", for: .normal)
        typeButton.setImage(StyleKit.imageOfPasswordTypeHeader, for: .normal)
        passwordButton.setImage(StyleKit.imageOfPasswordHeader, for: .normal)
        strengthButton.setImage(StyleKit.imageOfPasswordStrengthHeader, for: .normal)
        lengthButton.setImage(StyleKit.imageOfPasswordLengthHeader, for: .normal)
    }
    
    @IBAction func clickedSortButton(_ sender: UIButton) {
        var sort = ""
        if sender == typeButton {
            sort = "type"
        } else if sender == passwordButton {
            sort = "password"
        } else if sender == lengthButton {
            sort = "length"
        } else if sender == strengthButton {
            sort = "strength"
        }
        changeSort(sort)
    }
    func changeSort(_ sortKey: String) {
        if sortKey != sortedBy {
            sortedBy = sortKey
            ascending = false
        } else {
            ascending = !ascending
        }
        let sort = NSSortDescriptor.init(key: sortedBy, ascending: ascending)
        s.setSortDescriptor(sort)
        storedPasswordsTable.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        ascending = true
        changeSort("time")
        //when view appears, select the first password when generating
        selectFirstPassword = true
    }
    override func generatePassword() -> String {
        var index : UInt = 0
        if !selectFirstPassword {
            index = UInt(SecureRandom.randomInt(uint(s.count())))
        }
        selectFirstPassword = false
        selectPasswordAtIndex(index)
        d.setObject(index, forKey: "storedPasswordTableSelectedRow")
        return super.generatePassword()
        
    }
    func selectPasswordAtIndex(_ index: UInt){
        if s.count() == 0 {
            return
        }
        if index > s.count() - 1 {
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
