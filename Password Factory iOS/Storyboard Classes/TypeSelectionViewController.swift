//
//  TypeSelectionViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TypeSelectionViewController: UIViewController, DefaultsManagerDelegate, ControlViewDelegate, AlertViewControllerDelegate, PreferencesViewControllerDelegate {

    let passwordController = PasswordController.get(false)!
    var mainStoryboard: UIStoryboard?
    var keyboardDismissGesture: UITapGestureRecognizer?
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    let s = PasswordStorage.get()!
    let queue = OperationQueue()
    var currentViewController: PasswordsViewController?
    var viewControllers = [PFPasswordType : UIViewController]()
    var extendedCharacterRegex: NSRegularExpression?
    @IBOutlet weak var zoomButton: ZoomButton!
    @IBOutlet weak var crackTimeButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var passwordTypeTitle: UILabel!
    @IBOutlet weak var strengthMeter: StrengthMeter!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var typeSelectionControl: UISegmentedControl!
    
    var passwordFont = UIFont.systemFont(ofSize: 24.0)
    @IBOutlet weak var passwordScrollView: UIScrollView!
    @IBOutlet weak var passwordDisplay: UILabel!
    @IBOutlet weak var passwordLengthDisplay: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        do {
            extendedCharacterRegex = try NSRegularExpression.init(pattern: "[^A-Za-z0-9\(c.escapedSymbols)]", options: .caseInsensitive)
        } catch {
            extendedCharacterRegex = nil
        }
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
        setSelectedPasswordType()
        selectType(typeSelectionControl)
        
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
    @IBAction func selectType(_ sender: UISegmentedControl) {
        let selType = passwordController.getPasswordType(by: UInt(typeSelectionControl.selectedSegmentIndex))
        if selType == .storedType {
            generateButton.isEnabled = false
        } else {
            generateButton.isEnabled = true
        }
        currentViewController?.view.removeFromSuperview()

        guard let selectedViewController = getViewController(selType) else {
            return
        }
        guard let currentView = selectedViewController.view else {
            return
        }
        passwordTypeTitle.text = c.getNameFor(type: selType)
        currentViewController = selectedViewController
        
        controlsView.addSubview(currentView)
        controlsView.fillViewInContainer(currentView)
        currentViewController?.didMove(toParentViewController: self)
        d.setInteger(selType.rawValue, forKey: "selectedPasswordType")
        generatePassword()
    }
    func updateAndSelectSegment() {
        let currSel = typeSelectionControl.selectedSegmentIndex
        setupSegments()
        setSelectedPasswordType()
        if currSel != typeSelectionControl.selectedSegmentIndex {
            selectType(typeSelectionControl)
        }
    }
    /// Displays the preferences modal
    ///
    /// - Parameter sender: default sender
    @IBAction func pressedPreferencesButton(_ sender: UIButton) {
        if let vc = mainStoryboard?.instantiateViewController(withIdentifier: "PreferencesView") as? PreferencesViewController {
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            if let r = view.parentViewController {
                r.present(vc, animated: true, completion: nil)
            }
        }
    }
    func preferencesDismissed(defaultsReset: Bool) {
        if defaultsReset {
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
            zoomViewController.modalPresentationStyle = .popover
            let size = zoomViewController.formatPassword(password: passwordDisplay.text ?? "")
            if let pop = zoomViewController.popoverPresentationController {
                pop.permittedArrowDirections = .any
                pop.backgroundColor = zoomViewController.bgColor
                pop.sourceView = zoomButton
                pop.sourceRect = zoomButton.bounds
                let height = (size.height + 4.0) * ceil(size.width / 580)
                let width = size.width < 600 ? (size.width + 40) : 600
                
                zoomViewController.preferredContentSize = CGSize.init(width: width, height: height)
            }
            present(zoomViewController, animated: true, completion:{
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
        if let currPass = passwordDisplay.text {
            UIPasteboard.general.string = currPass
        }
    }
    
    func controlChanged(_ control: UIControl?, defaultsKey: String) {
        generatePassword()
    }
    
    /// Generates password from the current view controller
    func generatePassword() {
        let active = d.bool(forKey: "activeControl")
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
                if p.count == 0 || strength == 0 {
                    print("BREAKPOINT LOG - COUNT STRENGTH ZERO")
                }
                //update the password field
                DispatchQueue.main.async { [unowned self, p, strength, crackTime] in
                    self.updatePasswordField(p, strength: Double(strength), crackTime: crackTime)
                }
                if type != .storedType && !active {
                    //store on the main thread
                    DispatchQueue.main.async { [unowned self, p, strength, type] in
                        if strength / 100.0 == 0 && p.count > 0 {
                            print("BREAKPOINT LOG - ZERO STRENGTH")
                        }
                        self.s.storePassword(p, strength: Float(strength / 100.0), type: type)
                    }
                }
            }
        }
    }

    /// Updates the password field with the attributed text as well as updating the length counter
    ///
    /// - Parameter password: password to put in field
    func updatePasswordField(_ password: String, strength: Double, crackTime: String) {
        if password.count == 0 {
            print("BREAKPOINT LOG - ZERO PASSWORD")
        }
        strengthMeter.updateStrength(s: strength)
        var showExtendedCharacterAlert = false
        if let r = extendedCharacterRegex {
            if (!d.bool(forKey: "hideExtendedCharacterWarning")) {
                let m = r.matches(in: password, options: [], range: NSRange.init(location: 0, length: (password as NSString).length))
                if m.count > 0 {
                    showExtendedCharacterAlert = true
                }
            }
        }
        if showExtendedCharacterAlert {
            Utilities.showAlert(delegate: self, alertKey: "extendedCharacterWarning", parentViewController: self, disableAlertHiding: true, onlyContinue: true, source: passwordDisplay)
            d.setBool(true, forKey: "hideExtendedCharacterWarning")
        } else {
            updatePasswordField(password, crackTime: crackTime)
        }
    }
    private func updatePasswordField(_ password: String, crackTime: String) {
        var size = (password as NSString).size(withAttributes: [NSAttributedStringKey.font: passwordFont])
        size = CGSize.init(width: size.width, height: passwordDisplay.frame.size.height)
        passwordDisplay.attributedText = Utilities.highlightPassword(password: password, font: passwordFont)
        passwordDisplay.frame.size = size
        passwordScrollView.contentSize = size
        passwordLengthDisplay.text = "\(passwordDisplay.text?.count ?? 0)"
        crackTimeButton.setTitle(crackTime.uppercased(), for: .normal)
    }
    func canContinueWithAction(canContinue: Bool) {
        generatePassword()
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
    }
    
    /// Removes all password view controllers from the viewControllers dict, and child view controllers
    func removeChildViewControllers() {
        viewControllers.removeAll()
        _ = childViewControllers.map{ $0.willMove(toParentViewController: nil); $0.removeFromParentViewController() }
    }
}

