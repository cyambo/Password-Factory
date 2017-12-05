//
//  TabViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    var randomPasswordViewController: PasswordContainerViewController?
    var patternPasswordViewController: PasswordContainerViewController?
    var pronounceablePasswordViewController: PasswordContainerViewController?
    var mainStoryboard: UIStoryboard?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        randomPasswordViewController = (mainStoryboard?.instantiateViewController(withIdentifier: "Container") as? PasswordContainerViewController) ?? PasswordContainerViewController()
        randomPasswordViewController?.setType(type: .randomType)
        patternPasswordViewController = (mainStoryboard?.instantiateViewController(withIdentifier: "Container") as? PasswordContainerViewController) ?? PasswordContainerViewController()
        patternPasswordViewController?.setType(type: .patternType)
        pronounceablePasswordViewController = (mainStoryboard?.instantiateViewController(withIdentifier: "Container") as? PasswordContainerViewController) ?? PasswordContainerViewController()
        pronounceablePasswordViewController?.setType(type: .pronounceableType)
        viewControllers = [randomPasswordViewController!,patternPasswordViewController!,pronounceablePasswordViewController!]

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
