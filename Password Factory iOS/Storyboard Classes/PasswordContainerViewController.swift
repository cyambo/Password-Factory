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
    let controller = PasswordController.get(false)
    let d = DefaultsManager.get()
    var image: UIImage?
    var type: PFPasswordType = .randomType
    @IBInspectable public var num: Int = 0
    
    @IBOutlet weak var bigTypeImage: BigTypeIconView!
    @IBOutlet weak var containerView: ControlsContainer!
    @IBOutlet weak var strengthMeter: StrengthMeter!
    @IBOutlet weak var passwordLengthDisplay: UILabel!
    @IBOutlet weak var passwordTextView: PasswordTextView!
    
    var passwordViewController: PasswordsViewController?
    var passwordFont = UIFont.systemFont(ofSize: 24.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordFont = passwordTextView.font ?? passwordFont
    }
    func setType(type: PFPasswordType) {
        self.type = type
        let typeName = c.getNameFor(type: type)
        image = TypeIcons.getTypeIcon(type)
        tabBarItem = UITabBarItem.init(title: typeName, image: image, tag: type.rawValue)
        tabBarItem.tag = type.rawValue
        let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        passwordViewController = mainStoryboard.instantiateViewController(withIdentifier: typeName + "Password") as? PasswordsViewController
        if let p = passwordViewController {
            p.setup(type: type)
            addChildViewController(p)
        }
    }

    @IBAction func pressedZoomButton(_ sender: UIButton) {
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (containerView.subviews.count == 0 ){
            if let pv = passwordViewController?.view {
                containerView.addSubview(pv)
                let vd = ["p" : pv ]
                pv.translatesAutoresizingMaskIntoConstraints = false
                let hc = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[p]-(8)-|", options: [], metrics: nil, views: vd)
                let vc = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(8)-[p]-(8)-|", options: [], metrics: nil, views: vd)
                containerView?.addConstraints(hc)
                containerView?.addConstraints(vc)
                bigTypeImage.setImage(type: type)
            }

        }
        passwordTextView.textContainer.lineBreakMode = .byCharWrapping
        generatePassword()
    }
    @IBAction func pressedGenerateButton(_ sender: Any) {
        generatePassword()
    }
    func generatePassword() {
        controller?.generatePassword(type)
        if let pw = controller?.password {
            passwordTextView.attributedText = Utilities.highlightPassword(password: pw, font: passwordFont)
        } else {
            passwordTextView.text = ""
        }
        
        if let s = controller?.getPasswordStrength() {
            strengthMeter.updateStrength(s: Double(s))
        }

        passwordLengthDisplay.text = "\(passwordTextView.text.count)"
    }
}
