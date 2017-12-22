//
//  PreferencesViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController, ControlViewDelegate  {
    
    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLayoutSubviews() {
        controlsContainer.roundCorners()
        titleLabel.roundCorners(corners: [.topLeft, .topRight])
        controlsContainer.dropShadow()

        titleLabel.backgroundColor = PFConstants.tintColor
        titleLabel.textColor = UIColor.white
        doneButton.addBorder([.top],color: PFConstants.tintColor)
    }
    func controlChanged(_ control: UIControl?, defaultsKey: String) {
        if let isOn = (control as? UISwitch)?.isOn {
            if defaultsKey == "storePasswords" && !isOn {
                //TODO: add alert
                PasswordStorage.get().deleteAllEntities()
            }
        }

    }
    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}