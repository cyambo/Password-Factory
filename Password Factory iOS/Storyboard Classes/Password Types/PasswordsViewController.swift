//
//  PasswordsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// Superclass for all password types view
class PasswordsViewController: UIViewController  {


    @IBOutlet weak var lengthDisplay: UILabel! //label to show slider value
    @IBOutlet weak var lengthSlider: UISlider! //password length slider
    
    @IBOutlet weak var separatorTypeView: SelectTypesView!
    @IBOutlet weak var caseTypeView: SelectTypesView!
    
    let c = PFConstants.instance
    let d = DefaultsManager.get()!
    let f = PasswordFactory.get()!
    var passwordViewController: UIViewController?
    var passwordType = PFPasswordType.randomType

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setup(type: PFPasswordType) {
        passwordType = type
    }

    


    
    
}
