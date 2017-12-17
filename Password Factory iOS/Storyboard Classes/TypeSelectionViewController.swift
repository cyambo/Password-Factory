//
//  TypeSelectionViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TypeSelectionViewController: UIViewController, UITextFieldDelegate {
    
    let passwordController = PasswordController.get(false)!
    var mainStoryboard: UIStoryboard?
    var keyboardDismissGesture: UITapGestureRecognizer?
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    var currentViewController: PasswordsViewController?
    
    @IBOutlet weak var passwordTypeTitle: UILabel!
    @IBOutlet weak var strengthMeter: StrengthMeter!
    @IBOutlet weak var bigType: BigTypeIconView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var typeSelectionControl: UISegmentedControl!
    
    @IBOutlet weak var passwordDisplayWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordScrollView: UIScrollView!
    @IBOutlet weak var passwordDisplay: UITextField!
    var passwordFont = UIFont.systemFont(ofSize: 24.0)
    @IBOutlet weak var passwordLengthDisplay: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        setObservers()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegments()
        if keyboardDismissGesture == nil {
            //setting a tap gesture to dismiss keyboard when tapped outside of keyboard view
            keyboardDismissGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
            keyboardDismissGesture?.cancelsTouchesInView = false
            self.view.addGestureRecognizer(keyboardDismissGesture!)
        }

        passwordFont = passwordDisplay.font ?? passwordFont
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedPasswordType()
        selectType(typeSelectionControl)
        generatePassword()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    

    /// Inserts the segments based upon preferences
    func setupSegments() {
        passwordController.useStoredType = d?.bool(forKey: "storePasswords") ?? false
        passwordController.useAdvancedType = d?.bool(forKey: "enableAdvanced") ?? false
        
        typeSelectionControl.removeAllSegments()
        for i in 0 ..< passwordController.getFilteredPasswordTypes().count {
            let currType = passwordController.getPasswordType(by: UInt(i))
            let image = TypeIcons.getTypeIcon(currType)
            typeSelectionControl.insertSegment(with: image, at: i, animated: true)
        }
        
    }
    /// Called when type is selected on the segmented control - animates the next one into the view
    ///
    /// - Parameter sender: default sender
    
    @IBAction func selectType(_ sender: UISegmentedControl) {
        
        let selType = passwordController.getPasswordType(by: UInt(typeSelectionControl.selectedSegmentIndex))
        bigType.setImage(type: selType)
        guard let selectedViewController = getViewController(selType) else {
            return
        }
        guard let currentView = selectedViewController.view else {
            return
        }
        passwordTypeTitle.text = c.getNameFor(type: selType)
        controlsView.removeSubviewsAndConstraints()
        currentViewController = selectedViewController
        
        controlsView.addSubview(currentView)
        Utilities.fillViewInContainer(currentView, superview: view)
        
        self.d?.setInteger(selType.rawValue, forKey: "selectedPasswordType")
        
    }
    
    @IBAction func pressedPreferencesButton(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PreferencesView") as? PreferencesViewController {
            vc.modalPresentationStyle = .overCurrentContext
            
            if let r = UIApplication.shared.keyWindow?.rootViewController {
                r.present(vc, animated: true, completion: nil)
            }
        }
    }
    @IBAction func pressedZoomButton(_ sender: UIButton) {
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
        //        if let currPass = currentViewController?.passwordTextView.text {
        //            UIPasteboard.general.string = currPass
        //        }
        
    }
    func generatePassword() {
        
        guard let p = currentViewController?.generatePassword() else {
            passwordDisplay.text = ""
            strengthMeter.updateStrength(s: 0.0)
            passwordLengthDisplay.text = "0"
            return
        }
        updatePasswordField(p)


    }
    func updatePasswordField(_ password: String) {
        passwordLengthDisplay.text = "\(passwordDisplay.text?.count ?? 0)"
        strengthMeter.updateStrength(s: Double(currentViewController?.passwordStrength ?? 0.0))
        var size = (password as NSString).size(withAttributes: [NSAttributedStringKey.font: passwordFont])
        size = CGSize.init(width: size.width, height: passwordDisplay.frame.size.height)
        passwordDisplay.attributedText = Utilities.highlightPassword(password: password, font: passwordFont)
        passwordDisplay.frame.size = size
        passwordScrollView.contentSize = size
        passwordDisplayWidthConstraint.constant = size.width
        passwordScrollView.scrollRectToVisible(CGRect.init(x: size.width-1, y: 0, width: 1, height: 1), animated: true)
    }
    /// selects the current password type on the segmented control
    func setSelectedPasswordType() {
        guard let typeInt = d?.integer(forKey: "selectedPasswordType") else {
            return
        }
        guard let currType = PFPasswordType.init(rawValue: typeInt) else {
            return
        }
        let index = passwordController.getIndexBy(currType)
        typeSelectionControl.selectedSegmentIndex = Int(index)
        
    }
    
    /// Gets the view controller for password type
    ///
    /// - Parameter passwordType: password type of vc to get
    /// - Returns: view controller
    func getViewController(_ passwordType: PFPasswordType) -> PasswordsViewController? {
        
        let typeName = c.getNameFor(type: passwordType)
        if let vc = mainStoryboard?.instantiateViewController(withIdentifier: typeName + "Password") as? PasswordsViewController {
            return vc
        }
        
        return nil
    }
    
    /// sets observers for all the values in defaults plist
    func setObservers() {
        guard let plist = d?.prefsPlist else {
            return
        }
        let defaults = DefaultsManager.standardDefaults()
        for (key, _) in plist {
            let k = String(describing: key)
            defaults?.addObserver(self, forKeyPath: k, options: .new, context: nil)
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //whenever a default changes, generate a password
        
        //TODO: do not generate on color changes
        if keyPath == "enableAdvanced" || keyPath == "storePasswords" {
            setupSegments()
            setSelectedPasswordType()
        } else {
            generatePassword()
        }
        
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updatePasswordField(textField.text ?? "")
        if string == "\n" {
            textField.endEditing(true)
            return false
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

