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
        //does any special actions for control changes in preferences
        switch defaultsKey {
        case "enableAdvanced":
            //update the home screen actions when advanced is changed
            Utilities.setHomeScreenActions()
        case "storePasswords":
            //if store passwords is turned off, delete everything
            if let isOn = (control as? UISwitch)?.isOn {
                if !isOn {
                    PasswordStorage.get().deleteAllEntities()
                }
            }
            Utilities.setRemoteStore()
        case "resetAllDialogs":
            //reset the dialogs and pop to type selection
            self.d.resetDialogs()
            self.navigationController?.popViewController(animated: true)
        case "resetToDefaults":
            //delete all stored passwords, and restore defaults
            didResetDefaults = true
            PasswordStorage.get().deleteAllEntities()
            DefaultsManager.restoreUserDefaults()
            self.navigationController?.popViewController(animated: true)

        case "homeScreenShortcut":
            //push the home actions controller on 
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            navigationController?.pushViewController(mainStoryboard.instantiateViewController(withIdentifier: "HomeActionView") , animated: true)
        case "enableRemoteStore":
            Utilities.setRemoteStore()
            if d.bool(forKey: "enableRemoteStore") {
                didResetDefaults = true
                self.navigationController?.popViewController(animated: true)
            }
        case "eraseRemoteStore":
            DefaultsManager.removeRemoteDefaults()
//            PasswordStorage.get().deleteAllRemoteObjects()
            
        default:
            return
        }

    }
}
