//
//  ContainerViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PasswordContainerViewController: UIViewController {
    let c = PFConstants.instance
    var image: UIImage?
    var type: PFPasswordType = .randomType
    @IBInspectable public var num: Int = 0
    @IBOutlet weak var containerView: ControlsContainer!
    var passwordViewController: PasswordsViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func setType(type: PFPasswordType) {
        self.type = type
        let typeName = c.getNameFor(type: type)
        image = TypeIcons.getTypeIcon(type: type)
        tabBarItem = UITabBarItem.init(title: typeName, image: image, tag: type.rawValue)
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        passwordViewController = mainStoryboard.instantiateViewController(withIdentifier: typeName + "Password") as? PasswordsViewController
        if let p = passwordViewController {
            p.setup(type: type)
            addChildViewController(p)
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (containerView.subviews.count > 0 ){
            return
        }
        let pv = passwordViewController?.view ?? UIView()
        containerView.addSubview(pv)
        let vd = ["p" : pv ]
        pv.translatesAutoresizingMaskIntoConstraints = false
        let hc = NSLayoutConstraint.constraints(withVisualFormat: "H:|[p]|", options: [], metrics: nil, views: vd)
        let vc = NSLayoutConstraint.constraints(withVisualFormat: "V:|[p]|", options: [], metrics: nil, views: vd)
        containerView?.addConstraints(hc)
        containerView?.addConstraints(vc)
  
    }
    
}
