//
//  TabViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    let passwordController = PasswordController.get(false)!
    var mainStoryboard: UIStoryboard?
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        passwordController.useStoredType = false
        passwordController.useAdvancedType = false
        //initializing all the view controllers and putting them in the tab view
        var newVc = [UIViewController]()
        for i in 0 ..< passwordController.getFilteredPasswordTypes().count {
            if let vc = mainStoryboard?.instantiateViewController(withIdentifier: "Container") as? PasswordContainerViewController {
                vc.setType(type: passwordController.getPasswordType(by: UInt(i)))
                newVc.append(vc)
            }
        }
        viewControllers = newVc

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting a tap gesture to dismiss keyboard when tapped outside of keyboard view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

}
