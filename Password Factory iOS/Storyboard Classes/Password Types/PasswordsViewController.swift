//
//  PasswordsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Superclass for all password types view
class PasswordsViewController: UIViewController, ControlViewDelegate  {

    @IBInspectable public var passwordTypeInt: Int = 401 //Password type of item
    let c = PFConstants.instance
    let d = DefaultsManager.get()
    let f = PasswordFactory.get()!
    var typeSelectionViewController : TypeSelectionViewController?
    
    var passwordStrength: Float = 0.0
    var crackTimeString: String = ""
    var currentPassword = ""
    var passwordType = PFPasswordType.randomType
    let controller = PasswordController.get(false)
    
    override func viewWillAppear(_ animated: Bool) {
        passwordType = PFPasswordType.init(rawValue: passwordTypeInt) ?? PFPasswordType.randomType
        super.viewWillAppear(animated)
    }

    func controlChanged(_ control: UIControl?, defaultsKey: String) {
        typeSelectionViewController?.controlChanged(control, defaultsKey: defaultsKey)
    }
    func generatePassword() -> String {
        currentPassword = ""
        controller?.generatePassword(passwordType)
        guard let password = controller?.password else {
            return ""
        }
        currentPassword = password
        updateStrength(withCrackTime: d.bool(forKey: "displayCrackTime"))
        return currentPassword
    }
    func updateStrength(withCrackTime: Bool) {
        crackTimeString = ""
        passwordStrength = 0.0
        controller?.generateCrackTimeString = withCrackTime
        controller?.updatePasswordStrength()
        if withCrackTime {
           crackTimeString = controller?.getCrackTimeString() ?? ""
        }
        passwordStrength = controller?.getPasswordStrength() ?? 0.0
    }
}
