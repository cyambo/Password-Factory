//
//  PasswordsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PasswordsViewController: UIViewController  {


    @IBOutlet weak var lengthDisplay: UILabel!
    @IBOutlet weak var lengthSlider: UISlider!
    
    @IBOutlet weak var separatorTypeView: SelectTypesView!
    @IBOutlet weak var caseTypeView: SelectTypesView!
    
    let c = PFConstants.instance
    let d = DefaultsManager.get()!
    let f = PasswordFactory.get()!
    var passwordViewController: UIViewController?
    var passwordType = PFPasswordType.randomType
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setup(type: PFPasswordType) {
        passwordType = type
    }

    func setupLengthSlider() {
        lengthSlider.minimumValue = 5.0
        lengthSlider.maximumValue = d.float(forKey: "maxPasswordLength")
        lengthSlider.setValue(d.float(forKey: "passwordLength"), animated: false)
    }

    func lengthChanged() {
        let length = Int(lengthSlider.value)
        lengthDisplay.text = "\(length)"
        d.setInteger(Int(lengthSlider.value), forKey: "passwordLength")
    }
    @IBAction func changeLengthSlider(_ sender: UISlider) {
        lengthChanged()
    }

    
    
}
