//
//  TypeSelectionViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TypeSelectionViewController: UIViewController, UITextViewDelegate {
    
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
    
    @IBOutlet weak var passwordDisplay: UITextView!
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
        passwordDisplay.textContainer.lineBreakMode = .byCharWrapping
        passwordDisplay.textContainer.maximumNumberOfLines = 1
        passwordFont = passwordDisplay.font ?? passwordFont
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedPasswordType()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectType(typeSelectionControl)
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
        
//        controller?.setPasswordValue(passwordTextView.text)
//        controller?.updatePasswordStrength()
//        passwordTextView.attributedText = Utilities.highlightPassword(password: passwordTextView.text, font: passwordFont)
//        updateStrength()
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
            
//        if selType == .patternType {
            controlsView.addSubview(currentView)
            Utilities.fillViewInContainer(currentView, superview: view)
            
//        } else {
//            let scroll = UIScrollView.init()
//            controlsView.addSubview(scroll)
//            Utilities.fillViewInContainer(scroll, superview: self.view, padding: 16)
//            scroll.addSubview(currentView)
//            scroll.contentSize = CGSize.init(width: (scroll.frame.size.width - 16.0), height: currentView.frame.size.height)
//            scroll.isDirectionalLockEnabled = true
            
//        }
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
        currentViewController?.generatePassword()
    }
    
    /// Copies the password to the pasteboard
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedCopyButton(_ sender: Any) {
//        if let currPass = currentViewController?.passwordTextView.text {
//            UIPasteboard.general.string = currPass
//        }
        
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
        }
        if keyPath != "selectedPasswordType" {
            currentViewController?.generatePassword()
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
