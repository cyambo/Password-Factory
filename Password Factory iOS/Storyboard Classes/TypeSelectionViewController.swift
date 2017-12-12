//
//  TypeSelectionViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TypeSelectionViewController: UIViewController {
    let passwordController = PasswordController.get(false)!
    var mainStoryboard: UIStoryboard?
    var keyboardDismissGesture: UITapGestureRecognizer?
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    var currentViewController: PasswordContainerViewController?
    
    @IBOutlet weak var bigType: BigTypeIconView!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var typeSelectionControl: UISegmentedControl!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        setObservers()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: use defaults for random and stored
        passwordController.useStoredType = true
        passwordController.useAdvancedType = true

        typeSelectionControl.removeAllSegments()
        for i in 0 ..< passwordController.getFilteredPasswordTypes().count {
            let currType = passwordController.getPasswordType(by: UInt(i))
            let image = TypeIcons.getTypeIcon(currType)
            typeSelectionControl.insertSegment(with: image, at: i, animated: true)
        }
        if keyboardDismissGesture == nil {
            //setting a tap gesture to dismiss keyboard when tapped outside of keyboard view
            keyboardDismissGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
            keyboardDismissGesture?.cancelsTouchesInView = false
            self.view.addGestureRecognizer(keyboardDismissGesture!)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSelectedPasswordType()
        selectType(typeSelectionControl)
    }
    @IBAction func selectType(_ sender: UISegmentedControl) {
        let selType = c.getPasswordType(by: UInt(typeSelectionControl.selectedSegmentIndex))
        bigType.setImage(type: selType)
        
        if let currVc = getViewController(selType) {
            controlsView.removeSubviewsAndConstraints()
            controlsView.addSubview(currVc.view)
            Utilities.fillViewInContainer(currVc.view, superview: controlsView)
            currentViewController = currVc
        }
        d?.setInteger(selType.rawValue, forKey: "selectedPasswordType")
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
        if let currPass = currentViewController?.passwordTextView.text {
            UIPasteboard.general.string = currPass
        }
        
    }
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
    func getViewController(_ passwordType: PFPasswordType) -> PasswordContainerViewController? {
        let storyboardIdentifier: String
        if passwordType == .advancedType || passwordType == .storedType {
            storyboardIdentifier = "BigContainer"
        } else {
            storyboardIdentifier = "Container"
        }
        
        if let vc = mainStoryboard?.instantiateViewController(withIdentifier: storyboardIdentifier) as? PasswordContainerViewController {
            vc.setType(type: passwordType)
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
        currentViewController?.generatePassword()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
