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
class PreferencesViewController: UIViewController, ControlViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    weak var delegate: PreferencesViewControllerDelegate?
    let d = DefaultsManager.get()
    var didResetDefaults: Bool = false

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        if parent == nil {
            delegate?.preferencesDismissed(defaultsReset: didResetDefaults)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         scrollView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.96, alpha:1.0)
        navigationItem.title = "Preferences"
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
            self.d.resetDialogs()
            self.navigationController?.popViewController(animated: true)
        } else if defaultsKey == "resetToDefaults" {
            DefaultsManager.restoreUserDefaults()
            didResetDefaults = true
            self.navigationController?.popViewController(animated: true)
        }
    }
}
