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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeButton.setTitle("", for: .normal)
        passwordButton.setTitle("", for: .normal)
        strengthButton.setTitle("", for: .normal)
        typeButton.setImage(StyleKit.imageOfPasswordTypeHeader, for: .normal)
        passwordButton.setImage(StyleKit.imageOfPasswordHeader, for: .normal)
        strengthButton.setImage(StyleKit.imageOfPasswordStrengthHeader, for: .normal)
        // Do any additional setup after loading the view.
    }
    override func generatePassword() -> String {
        //TODO: get random password from list for generate
        return "PaSSWoRD"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

        return currentCell
    }
    
}
