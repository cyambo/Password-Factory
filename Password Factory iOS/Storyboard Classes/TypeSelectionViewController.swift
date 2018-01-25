//
//  TypeSelectionViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TypeSelectionViewController: UIViewController, DefaultsManagerDelegate, ControlViewDelegate, AlertViewControllerDelegate, PreferencesViewControllerDelegate {


    let passwordController: PasswordController
    var mainStoryboard: UIStoryboard?
    var keyboardDismissGesture: UITapGestureRecognizer?
    
    let d: DefaultsManager
    let c: PFConstants

    let queue = OperationQueue()
    
    var currentViewController: PasswordsViewController?
    var viewControllers = [PFPasswordType : UIViewController]()
    
    var extendedCharacterRegex: NSRegularExpression?
    var savedPassword: String?
    
    @IBOutlet weak var zoomButton: ZoomButton!
    @IBOutlet weak var crackTimeButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var strengthMeter: StrengthMeter!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var typeSelectionControl: UISegmentedControl!
    
    var passwordFont = UIFont.systemFont(ofSize: 24.0)
    @IBOutlet weak var passwordScrollView: UIScrollView!
    @IBOutlet weak var passwordDisplay: UILabel!
    @IBOutlet weak var passwordLengthDisplay: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        Utilities.setRemoteStore()
        Utilities.setHomeScreenActions()
        passwordController = PasswordController.get()!
        d = DefaultsManager.get()
        c = PFConstants.instance
        
        super.init(coder: aDecoder)

        
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        do {
            extendedCharacterRegex = try NSRegularExpression.init(pattern: "[^A-Za-z0-9 \(c.escapedSymbols)]", options: .caseInsensitive)
        } catch {
            extendedCharacterRegex = nil
        }
        navigationController?.navigationBar.isTranslucent = false
        setObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSegments()
        //setup a global gesture that will dismiss the keyboard on a tap in the background
        if keyboardDismissGesture == nil {
            //setting a tap gesture to dismiss keyboard when tapped outside of keyboard view
            keyboardDismissGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
            keyboardDismissGesture?.cancelsTouchesInView = false
            view.addGestureRecognizer(keyboardDismissGesture!)
        }
        passwordDisplay.text = ""
        passwordFont = passwordDisplay.font ?? passwordFont
        crackTimeButton.setTitle("", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = setSelectedPasswordType()
        selectTypeFromControl(typeSelectionControl)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let p = d.prefsPlist {
            d.removeDefaultsObservers(self, keys: Array(p))
        }
        currentViewController?.view.removeFromSuperview()
        currentViewController = nil
        removeChildViewControllers()
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
    @IBAction func selectTypeFromControl(_ sender: UISegmentedControl) {
        let selType = passwordController.getPasswordType(by: UInt(typeSelectionControl.selectedSegmentIndex))
        selectAndDisplay(type: selType, copy: false)
    }
    
    /// Selects the current password type and displays the password view
    ///
    /// - Parameters:
    ///   - type: password type to display
    ///   - withCopy: if the password should be copied to clipboard
    func selectAndDisplay(type: PFPasswordType, copy withCopy: Bool) {
        if type == .storedType {
            generateButton.isEnabled = false
        } else {
            generateButton.isEnabled = true
        }
        currentViewController?.view.removeFromSuperview()
        
        guard let selectedViewController = getViewController(type) else {
            return
        }
        guard let currentView = selectedViewController.view else {
            return
        }
        navigationItem.title = c.getNameFor(type: type)
        currentViewController = selectedViewController
        
        controlsView.addSubview(currentView)
        controlsView.fillViewInContainer(currentView)
        currentViewController?.didMove(toParentViewController: self)
        d.setInteger(type.rawValue, forKey: "selectedPasswordType")
        generatePassword(withCopy: withCopy)
    }
    
    /// Updates the segments based upon preferences and selects a segment based on defaults
    func updateAndSelectSegment() {
        let currSel = typeSelectionControl.selectedSegmentIndex
        setupSegments()
        _ = setSelectedPasswordType()
        //only select a new segment if our selection changed because that segment was removed
        if currSel != typeSelectionControl.selectedSegmentIndex {
            selectTypeFromControl(typeSelectionControl)
        }
    }
    
    /// Pushes prefs onto navigation controller
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedPreferences(_ sender: Any) {
        if let vc = mainStoryboard?.instantiateViewController(withIdentifier: "PreferencesView") as? PreferencesViewController {
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// PreferencesViewController delegate method, called when prefs was dismissed
    ///
    /// - Parameter defaultsReset: true if the defaults were reset
    func preferencesDismissed(defaultsReset: Bool) {
        if defaultsReset {
            //if the defaults were reset, reload all the viewControllers and segments
            typeSelectionControl.selectedSegmentIndex = -1
            viewControllers.removeAll()
        }
        updateAndSelectSegment()
    }
    
    /// Toggles the display of the crack time over strength meter
    ///
    /// - Parameter sender: default sender
    @IBAction func toggleCrackTime(_ sender: UIButton) {
        let displayCT = !d.bool(forKey: "displayCrackTime")
        d.setBool(displayCT, forKey: "displayCrackTime")
        currentViewController?.updateStrength(withCrackTime: displayCT)
        crackTimeButton.setTitle(currentViewController?.crackTimeString.uppercased() ?? "", for: .normal)
    }
    
    /// Displays a zoomed password
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedZoomButton(_ sender: UIButton) {
        if let zoomViewController = mainStoryboard?.instantiateViewController(withIdentifier: "ZoomView") as? ZoomViewController {
            
            let size = zoomViewController.formatPassword(password: passwordDisplay.text ?? "")
            //setting the size of the popover to grow and shrink with the password size
            let height = (size.height + 4.0) * ceil(size.width / 580)
            let width = size.width < 600 ? (size.width + 40) : 600
            let contentBounds = CGRect.init(x: 0, y: 0, width: width, height: height)
            savedPassword = passwordDisplay.text //store the current password so it gets displayed when this view reappears
            Utilities.showPopover(parentViewController: self, viewControllerToShow: zoomViewController, popoverBounds: contentBounds, source: zoomButton, completion: {
                zoomViewController.zoomedPassword.scrollRangeToVisible(NSRange.init(location: 0, length: 0))
            })
        }
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
        copyPasswordToPasteboard()
    }
    
    /// Copies current password to pasteboard
    func copyPasswordToPasteboard() {
        if let currPass = passwordDisplay.text {
            UIPasteboard.general.string = currPass
        }
    }
    
    /// ControlView delegate method
    ///
    /// - Parameters:
    ///   - control: control that was changed
    ///   - defaultsKey: defaultsKey of control
    func controlChanged(_ control: UIControl?, defaultsKey: String) {
        generatePassword()
    }
    
    
    /// Generates password from the current view controller
    ///
    /// - Parameter withCopy: and if the password should be copied to clipboard
    func generatePassword(withCopy: Bool = false) {
        //if there is a stored password from the zoomView just show it
        if let sp = savedPassword {
            savedPassword = nil
            if let controller = PasswordController.get() {
                controller.password = sp
                controller.updatePasswordStrength()
                updatePasswordField(sp, strength: Double(controller.getPasswordStrength()), crackTime: controller.getCrackTimeString())
                return
            }
        }
        let active = d.bool(forKey: "activeControl") //activeControl is set when dragging or holding down the stepper
        //running the password generation if we are not an active control, or if we are an active control make sure the last operation finished
        if queue.operationCount == 0 {
            queue.addOperation { [unowned self, active] in
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
                guard let strength = self.currentViewController?.passwordStrength else {
                    return
                }
                let crackTime = self.currentViewController?.crackTimeString ?? ""

                //update the password field
                DispatchQueue.main.async { [unowned self, p, strength, crackTime] in
                    self.updatePasswordField(p, strength: Double(strength), crackTime: crackTime)
                    if withCopy {
                        self.copyPasswordToPasteboard()
                    }
                }
                //store if we are not active or a stored type
                if type != .storedType && !active && self.d.bool(forKey: "storePasswords"){
                    //store on the main thread
                    DispatchQueue.main.async { [p, strength, type] in
                        PasswordStorage.get()!.storePassword(p, strength: Float(strength), type: type)
                    }
                }
            }
        }
    }

    /// Updates the password field with the attributed text as well as updating the length counter
    ///
    /// - Parameter password: password to put in field
    func updatePasswordField(_ password: String, strength: Double, crackTime: String) {
        strengthMeter.updateStrength(s: strength)
        var showExtendedCharacterAlert = false
        //checking to see if we displayed an extended character
        if let r = extendedCharacterRegex {
            //and if it wasn't hidden
            if (!d.bool(forKey: "hideExtendedCharacterWarning")) {
                //checking to see if there was an extended character
                let m = r.matches(in: password, options: [], range: NSRange.init(location: 0, length: (password as NSString).length))
                if m.count > 0 {
                    showExtendedCharacterAlert = true
                }
            }
        }
        //there was an extended character, so show the alert only once
        if showExtendedCharacterAlert {
            Utilities.showAlert(delegate: self, alertKey: "extendedCharacterWarning", parentViewController: self, disableAlertHiding: true, onlyContinue: true, source: passwordDisplay)
            d.setBool(true, forKey: "hideExtendedCharacterWarning")
        }
        updatePasswordField(password)
        //set the crack time string
        crackTimeButton.setTitle(crackTime.uppercased(), for: .normal)
    }
    
    /// Updates the password field, sets the length, and resizes the label so that it will scroll properly
    ///
    /// - Parameter password: password to display
    private func updatePasswordField(_ password: String) {
        let highlightedPassword = Utilities.highlightPassword(password: password, font: passwordFont)
        var size = highlightedPassword.size()
        size = CGSize.init(width: size.width, height: passwordDisplay.frame.size.height)
        passwordDisplay.attributedText = highlightedPassword
        passwordDisplay.frame.size = size
        passwordScrollView.contentSize = size
        passwordLengthDisplay.text = "\(passwordDisplay.text?.count ?? 0)"
    }
    
    /// AlertViewControllerDelegate method - called when alert is dismissed
    ///
    /// - Parameter canContinue: whether or not to continue with the action that triggered the alert
    func canContinueWithAction(canContinue: Bool) {
        generatePassword()
    }
    
    /// Selects password type from defaults and sets the segmented control to that value
    ///
    /// - Returns: type that was selected
    func setSelectedPasswordType() -> PFPasswordType? {
        //get the password type raw value
        let typeInt = d.integer(forKey: "selectedPasswordType")
        //convert it to enum
        guard let currType = PFPasswordType.init(rawValue: typeInt) else {
            return nil
        }
        //get the index
        let index = passwordController.getIndexBy(currType)
        //select it
        if typeSelectionControl != nil {
            typeSelectionControl.selectedSegmentIndex = Int(index)
        }
        
        return currType
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
            addChildViewController(vc)
            return vc
        }
        return nil
    }
    
    /// sets observers for the defaults keys we want to monitor
    func setObservers() {
        let toObserve = ["enableAdvanced", "storePasswords", "colorPasswordText", "upperTextColor", "lowerTextColor", "symbolTextColor", "defaultTextColor"]
        d.observeDefaults(self, keys: toObserve)
    }
    
    /// DefaultsManagerDelegate method - called when an observed key is changed
    ///
    /// - Parameters:
    ///   - keyPath: key changed
    ///   - change: change dictionary
    func observeValue(_ keyPath: String?, change: [AnyHashable : Any]?) {
        if let key = keyPath {
            //are we toggling advanced or stored
            if key == "enableAdvanced" || key == "storePasswords" {
                updateAndSelectSegment()
                return
            }
            //if not, we are updating colors
            updatePasswordField(passwordDisplay.text ?? "", strength: strengthMeter.strength * 100, crackTime: crackTimeButton.titleLabel?.text ?? "")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        removeChildViewControllers()
        updateAndSelectSegment()
    }
    
    /// Removes all password view controllers from the viewControllers dict, and child view controllers
    func removeChildViewControllers() {
        viewControllers.removeAll()
        _ = childViewControllers.map{ $0.willMove(toParentViewController: nil); $0.removeFromParentViewController() }
    }
}

