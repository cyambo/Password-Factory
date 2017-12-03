//
//  TabViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    var randomPasswordViewController: ContainerViewController?
    var patternPasswordViewController: ContainerViewController?
    var mainStoryboard: UIStoryboard?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        randomPasswordViewController = mainStoryboard?.instantiateViewController(withIdentifier: "Container") as? ContainerViewController
        randomPasswordViewController?.setType(type: .randomType)
        patternPasswordViewController = mainStoryboard?.instantiateViewController(withIdentifier: "Container") as? ContainerViewController
        patternPasswordViewController?.setType(type: .patternType)
        viewControllers = [randomPasswordViewController!,patternPasswordViewController!]
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
