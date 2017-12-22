//
//  TypeSelectionViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TypeSelectionViewController: UIViewController, UITextFieldDelegate, DefaultsManagerDelegate {
    
    let passwordController = PasswordController.get(false)!
    var mainStoryboard: UIStoryboard?
    var keyboardDismissGesture: UITapGestureRecognizer?
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    let s = PasswordStorage.get()!
    let queue = OperationQueue()
    var currentViewController: PasswordsViewController?
    var viewControllers = [PFPasswordType : UIViewController]()
    
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
        //setup a global gesture that will dismiss the keyboard on a tap in the background
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
    override func viewWillDisappear(_ animated: Bool) {
        if let p = d.prefsPlist {
            d.removeDefaultsObservers(self, keys: Array(p))
        }
    }
    /// Inserts the segments based upon preferences
    func setupSegments() {
        passwordController.useStoredType = d.bool(forKey: "storePasswords")
        passwordController.useAdvancedType = d.bool(forKey: "enableAdvanced")
        
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
        currentViewController?.view.removeFromSuperview()
        let selType = passwordController.getPasswordType(by: UInt(typeSelectionControl.selectedSegmentIndex))
        guard let selectedViewController = getViewController(selType) else {
            return
        }
        guard let currentView = selectedViewController.view else {
            return
        }
        passwordTypeTitle.text = c.getNameFor(type: selType)

        currentViewController = selectedViewController
        
        controlsView.addSubview(currentView)
        view.fillViewInContainer(currentView)
        
        self.d.setInteger(selType.rawValue, forKey: "selectedPasswordType")
    }
    
    /// Displays the preferences modal
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedPreferencesButton(_ sender: UIButton) {
        if let vc = mainStoryboard?.instantiateViewController(withIdentifier: "PreferencesView") as? PreferencesViewController {
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
        if let currPass = passwordDisplay.text {
            UIPasteboard.general.string = currPass
        }
    }
    
    /// Generates password from the current view controller
    func generatePassword() {
        //if there are any other generate operations, just cancel them
//        if (queue.operations.first != nil) {
//            queue.cancelAllOperations()
//        }
        //adding the generate option to the background
//        queue.addOperation { [unowned self] in

            guard let p = self.currentViewController?.generatePassword() else {
                DispatchQueue.main.async { [unowned self] in
                    self.passwordDisplay.text = ""
                    self.strengthMeter.updateStrength(s: 0.0)
                    self.passwordLengthDisplay.text = "0"
                }
                return
            }
            guard let type = self.currentViewController?.passwordType else {
                return
            }

            DispatchQueue.main.async { [unowned self] in
                self.updatePasswordField(p)
            }
            if type != .storedType {
                let active = self.d.bool(forKey: "activeControl")
                if !active  {
                    DispatchQueue.main.async {
                        self.s.storePassword(p, strength: Float((self.currentViewController?.passwordStrength ?? 0.0) / 100.0), type: (self.currentViewController?.passwordType)!)
                    }
                }
            }

        }
//    }

    /// Updates the password field with the attributed text as well as updating the length counter
    ///
    /// - Parameter password: password to put in field
    func updatePasswordField(_ password: String) {
        strengthMeter.updateStrength(s: Double(currentViewController?.passwordStrength ?? 0.0))
        var size = (password as NSString).size(withAttributes: [NSAttributedStringKey.font: passwordFont])
        size = CGSize.init(width: size.width, height: passwordDisplay.frame.size.height)
        passwordDisplay.attributedText = Utilities.highlightPassword(password: password, font: passwordFont)
        passwordDisplay.frame.size = size
        passwordScrollView.contentSize = size
        passwordDisplayWidthConstraint.constant = size.width
        passwordScrollView.scrollRectToVisible(CGRect.init(x: size.width-1, y: 0, width: 1, height: 1), animated: false)
        passwordLengthDisplay.text = "\(passwordDisplay.text?.count ?? 0)"
    }
    
    /// selects the current password type on the segmented control
    func setSelectedPasswordType() {
        //get the password type raw value
        let typeInt = d.integer(forKey: "selectedPasswordType")
        //convert it to enum
        guard let currType = PFPasswordType.init(rawValue: typeInt) else {
            return
        }
        //get the index
        let index = passwordController.getIndexBy(currType)
        //select it
        typeSelectionControl.selectedSegmentIndex = Int(index)
        
    }
    
    /// Gets the view controller for password type
    ///
    /// - Parameter passwordType: password type of vc to get
    /// - Returns: view controller
    func getViewController(_ passwordType: PFPasswordType) -> PasswordsViewController? {
        let typeName = c.getNameFor(type: passwordType)
        if let vc = viewControllers[passwordType] as? PasswordsViewController {
            return vc
        }
        if let vc = mainStoryboard?.instantiateViewController(withIdentifier: typeName + "Password") as? PasswordsViewController {
            viewControllers[passwordType] = vc
            vc.typeSelectionViewController = self
            return vc
        }
        
        return nil
    }
    
    /// sets observers for all the values in defaults plist
    func setObservers() {
        guard var plist = d.prefsPlist else {
            return
        }
        plist["activeControl"] = false
        d.observeDefaults(self, keys: Array(plist.keys))

    }
    func observeValue(_ keyPath: String?, change: [AnyHashable : Any]?) {
        //whenever a default changes, generate a password
        if keyPath == "storedPasswordTableSelectedRow" {
            return
        }
        //TODO: do not generate on color changes
        if keyPath == "enableAdvanced" || keyPath == "storePasswords" {
            setupSegments()
            setSelectedPasswordType()
            selectType(typeSelectionControl)
        } else {
            generatePassword()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //this is called when a user types in the password field
        //highlight and update the counter
        updatePasswordField(textField.text ?? "")
        //if the done button is pressed, didmiss the keyboard
        if string == "\n" {
            textField.endEditing(true)
            return false
        }
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        viewControllers.removeAll()
    }
    
    
}

