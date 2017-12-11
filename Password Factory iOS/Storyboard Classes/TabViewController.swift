//
//  TabViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// Controller for the tab view
class TabViewController: UITabBarController {
    
    let passwordController = PasswordController.get(false)!
    var mainStoryboard: UIStoryboard?
    var keyboardDismissGesture: UITapGestureRecognizer?
    let d = DefaultsManager.get()
    let c = PFConstants.instance
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        //TODO: use defaults for random and stored
        passwordController.useStoredType = false
        passwordController.useAdvancedType = true
        //initializing all the view controllers and putting them in the tab view
        var newVc = [UIViewController]()
        for i in 0 ..< passwordController.getFilteredPasswordTypes().count {
            let currType = passwordController.getPasswordType(by: UInt(i))
            let storyboardIdentifier: String
            if currType == .advancedType || currType == .storedType {
                storyboardIdentifier = "BigContainer"
            } else {
                storyboardIdentifier = "Container"
            }
            if let vc = mainStoryboard?.instantiateViewController(withIdentifier: storyboardIdentifier) as? PasswordContainerViewController {
                vc.setType(type: currType)
                newVc.append(vc)
            }
        }
        viewControllers = newVc
        setSelectedPasswordType()
        setObservers()

    }
    
    /// Selects the password type based upon defaults
    func setSelectedPasswordType() {
        guard let typeInt = d?.integer(forKey: "selectedPasswordType") else {
            return
        }
        guard let vcs = viewControllers else {
            return
        }
        var i = 0
        for vc in vcs {
            if vc.tabBarItem.tag == typeInt {
                selectedIndex = i
                break;
            }
            i = i + 1
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //setting current password type when tab bar changes
        guard let currentTitle = item.title else {
            return
        }
        guard let currentType = c.passwordNameToType[currentTitle] else {
            return
        }
        d?.setInteger(currentType.rawValue, forKey: "selectedPasswordType")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if keyboardDismissGesture == nil {
            //setting a tap gesture to dismiss keyboard when tapped outside of keyboard view
            keyboardDismissGesture = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
            keyboardDismissGesture?.cancelsTouchesInView = false
            self.view.addGestureRecognizer(keyboardDismissGesture!)
        }

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
        if let vc = selectedViewController as? PasswordContainerViewController { //select the current view controller
            vc.generatePassword() //generate the password
        }
    }

}
