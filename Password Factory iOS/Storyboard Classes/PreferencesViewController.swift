//
//  PreferencesViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PreferencesViewController: UIViewController {

    @IBOutlet weak var controlsContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLayoutSubviews() {
        Utilities.roundCorners(layer: controlsContainer.layer, withBorder: false)
        Utilities.roundCorners(view: titleLabel, corners: [.topLeft, .topRight], withBorder: false)
        Utilities.dropShadow(view: controlsContainer)
        titleLabel.backgroundColor = Utilities.tintColor
        titleLabel.textColor = UIColor.white
        doneButton.addTopBorderWithColor(color: Utilities.tintColor, width: 0.5)
        
    }

    @IBAction func done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
