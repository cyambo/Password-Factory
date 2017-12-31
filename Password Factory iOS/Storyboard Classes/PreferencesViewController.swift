//
//  PreferencesViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController, ControlViewDelegate  {
    
    @IBOutlet weak var doneButton: UIButton!

    func controlChanged(_ control: UIControl?, defaultsKey: String) {
        if let isOn = (control as? UISwitch)?.isOn {
            if defaultsKey == "storePasswords" && !isOn {
                //TODO: add alert
                PasswordStorage.get().deleteAllEntities()
            }
        }
    }
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
