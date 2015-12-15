//
//  RandomViewController.swift
//  Password Factory
//
//  Created by Cristiana Yambo on 12/4/15.
//  Copyright © 2015 Cristiana Yambo. All rights reserved.
//

import UIKit

class RandomViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordLength: UISlider!
    @IBOutlet weak var useSymbols: UISwitch!
    @IBOutlet weak var mixedCase: UISwitch!
    @IBOutlet weak var avoidAmbiguous: UISwitch!
    var factory = PasswordFactory();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generatePassword()
    
        // Do any additional setup after loading the view.
    }
    @IBAction func switchChanged(sender: AnyObject?=nil) {

        generatePassword()
    }


    @IBAction func passwordLengthChange(sender: AnyObject) {
        generatePassword()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func generatePassword() {
        factory.passwordLength = UInt(passwordLength.value)
        
        passwordField.text = factory.generateRandom(mixedCase.on, avoidAmbiguous: avoidAmbiguous.on, useSymbols: useSymbols.on)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
