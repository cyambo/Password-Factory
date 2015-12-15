//
//  PatternViewController.swift
//  Password Factory
//
//  Created by Cristiana Yambo on 12/4/15.
//  Copyright © 2015 Cristiana Yambo. All rights reserved.
//

import UIKit

class PatternViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var patternTextField: UITextField!
    var factory = PasswordFactory()
    override func viewDidLoad() {
        super.viewDidLoad()
        patternTextField.delegate = self;
        generatePassword()
    }

    @IBAction func changePattern(sender: AnyObject) {
        generatePassword()
    }
    func generatePassword() {
        passwordField.text = factory.generatePattern(patternTextField.text)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
