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
    @IBOutlet weak var scrollView: UIScrollView!

    let d = DefaultsManager.get()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         scrollView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
    }
    func controlChanged(_ control: UIControl?, defaultsKey: String) {
        //checking to see if storePasswords was disabled
        if defaultsKey == "storePasswords" {
            if let isOn = (control as? UISwitch)?.isOn {
                if !isOn {
                    PasswordStorage.get().deleteAllEntities()
                }
            }
        } else if defaultsKey == "resetAllDialogs" {
            dismiss(animated: true, completion: {
                self.d.resetDialogs()
            })
        } else if defaultsKey == "resetToDefaults" {
            dismiss(animated: true, completion: {
                DefaultsManager.restoreUserDefaults()
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
