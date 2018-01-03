//
//  PreferencesViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@objc public protocol PreferencesViewControllerDelegate: class {
    func preferencesDismissed(defaultsReset: Bool)
}
class PreferencesViewController: UIViewController, ControlViewDelegate  {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    weak var delegate: PreferencesViewControllerDelegate?
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
            dismiss(animated: true, completion: { [unowned self] in
                DefaultsManager.restoreUserDefaults()
                self.delegate?.preferencesDismissed(defaultsReset: true)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    @IBAction func done(_ sender: Any) {
        delegate?.preferencesDismissed(defaultsReset: false)
        self.dismiss(animated: true, completion: nil)
    }
    
}
