//
//  PasswordsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Superclass for all password types view
class PasswordsViewController: UIViewController  {

    @IBInspectable public var passwordTypeInt: Int = 401 //Password type of item
    let c = PFConstants.instance
    let d = DefaultsManager.get()
    let f = PasswordFactory.get()!
    var typeSelectionViewController : TypeSelectionViewController?
    
    var passwordStrength: Float = 0.0
    var strengthText = ""
    var currentPassword = ""
    var passwordType = PFPasswordType.randomType
    let controller = PasswordController.get(false)
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func awakeFromNib() {
        passwordType = PFPasswordType.init(rawValue: passwordTypeInt) ?? PFPasswordType.randomType
    }
    func generatePassword() -> String {
        passwordStrength = 0.0
        strengthText = ""
        currentPassword = ""
        controller?.generatePassword(passwordType)
        guard let password = controller?.password else {
            return ""
        }
        currentPassword = password
        if let s = controller?.getPasswordStrength() {
            passwordStrength = s
        }
        return currentPassword
        
    }
}
