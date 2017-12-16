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
    
    @IBOutlet weak var passwordViewHeight: NSLayoutConstraint!
    
    @IBOutlet var containerVerticalMargins: [NSLayoutConstraint]!
    @IBOutlet var containerHorizontalMargins: [NSLayoutConstraint]!
    

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var strengthMeter: StrengthMeter!
    @IBOutlet weak var passwordLengthDisplay: UILabel!
    @IBOutlet weak var passwordTextView: PasswordTextView!
    
    var passwordViewController: PasswordsViewController?
    var passwordFont = UIFont.systemFont(ofSize: 24.0)


    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.removeSubviews()
        if let pv = passwordViewController?.view {
            containerView.addSubview(pv)
        }
        passwordTextView.textContainer.lineBreakMode = .byCharWrapping
        passwordTextView.textContainer.maximumNumberOfLines = 1
        passwordFont = passwordTextView.font ?? passwordFont
        generatePassword()
    }
    override func viewWillLayoutSubviews() {
        if let pv = passwordViewController?.view {
            Utilities.fillViewInContainer(pv, superview: containerView, padding: 16)
        }
        
    }
    override func viewDidLayoutSubviews() {

        switch type {
        case .storedType, .advancedType:
            if passwordViewHeight.constant == 0.0 {
                containerHorizontalMargins.forEach{$0.constant = 4}
            }
        case .passphraseType, .pronounceableType:
            let h = containerView.frame.height
            if passwordViewHeight.constant == 0.0 {
                var c = h - 306.0
                c = c  / 3
                passwordViewHeight.constant = c
                containerVerticalMargins.forEach{$0.constant = c + $0.constant}
            }
        case .patternType:
            break
        case .randomType:
            let h = containerView.frame.height
            if h < 356 {
                passwordViewHeight.constant = h - 356
            } else {
                let c = (h - 356) / 2
                containerVerticalMargins.forEach{$0.constant = c + $0.constant}
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.passwordTextView.contentOffset.y = -self.passwordTextView.contentInset.top
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
//            p.setup(type: type)
            addChildViewController(p)
        }
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
