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

    
    /// Sets up the length slider with the maximum value and moves the knob to the defaults value
    func setupLengthSlider() {
        lengthSlider.minimumValue = 5.0
        lengthSlider.maximumValue = d.float(forKey: "maxPasswordLength")
        lengthSlider.setValue(d.float(forKey: "passwordLength"), animated: false)
    }
    
    /// Called when length is changed - sets defaults and label
    func lengthChanged() {
        let length = Int(lengthSlider.value)
        lengthDisplay.text = "\(length)"
        d.setInteger(Int(lengthSlider.value), forKey: "passwordLength")
    }
    
    /// action when length is changed
    ///
    /// - Parameter sender: default sender
    @IBAction func changeLengthSlider(_ sender: UISlider) {
        lengthChanged()
    }

    
    
}
