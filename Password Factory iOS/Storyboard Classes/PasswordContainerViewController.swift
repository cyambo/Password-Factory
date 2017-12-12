//
//  ContainerViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// View Controller that holds all the password views
class PasswordContainerViewController: UIViewController, UITextViewDelegate {
    
    let c = PFConstants.instance
    let controller = PasswordController.get(false)
    let d = DefaultsManager.get()
    var type: PFPasswordType = .randomType
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var strengthMeter: StrengthMeter!
    @IBOutlet weak var passwordLengthDisplay: UILabel!
    @IBOutlet weak var passwordTextView: PasswordTextView!
    
    var passwordViewController: PasswordsViewController?
    var passwordFont = UIFont.systemFont(ofSize: 24.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordFont = passwordTextView.font ?? passwordFont
    }
    
    /// Set the password type used in this contoller
    ///
    /// - Parameter type: type to set
    func setType(type: PFPasswordType) {
        self.type = type
        let typeName = c.getNameFor(type: type)


        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        passwordViewController = mainStoryboard.instantiateViewController(withIdentifier: typeName + "Password") as? PasswordsViewController
        if let p = passwordViewController {
            p.setup(type: type)
            addChildViewController(p)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (containerView.subviews.count == 0 ){
            //only add a new password control view if there are no views in the container
            if let pv = passwordViewController?.view {
                containerView.addSubview(pv)
                Utilities.fillViewInContainer(pv, superview: containerView, padding: 16)
                
            }
        }
        passwordTextView.textContainer.lineBreakMode = .byCharWrapping
        passwordTextView.textContainer.maximumNumberOfLines = 1
        generatePassword()
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //dismisses the keyboard when done is pressed
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        
        controller?.setPasswordValue(passwordTextView.text)
        controller?.updatePasswordStrength()
        passwordTextView.attributedText = Utilities.highlightPassword(password: passwordTextView.text, font: passwordFont)
        updateStrength()
    }
    @IBAction func pressedZoomButton(_ sender: UIButton) {
        //TODO: show zoom
    }
    
    /// Generates password when button is pressed
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedGenerateButton(_ sender: Any) {
        generatePassword()
    }
    
    /// Copies the password to the pasteboard
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedCopyButton(_ sender: Any) {
        UIPasteboard.general.string = passwordTextView.text
    }
    
    /// Generates a new password and updates strength
    func generatePassword() {
        controller?.generatePassword(type)
        //set highlighted password
        if let pw = controller?.password {
            passwordTextView.attributedText = Utilities.highlightPassword(password: pw, font: passwordFont)
        } else {
            passwordTextView.text = ""
        }
        updateStrength()
        passwordLengthDisplay.text = "\(passwordTextView.text.count)"
        //scroll to top
        passwordTextView.scrollRangeToVisible(NSRange.init(location: 0, length: 0))
    }
    func updateStrength() {
        //update the strength
        if let s = controller?.getPasswordStrength() {
            strengthMeter.updateStrength(s: Double(s))
        }
    }

}
