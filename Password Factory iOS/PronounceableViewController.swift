//
//  PronounceableViewController.swift
//  Password Factory
//
//  Created by Cristiana Yambo on 12/4/15.
//  Copyright © 2015 Cristiana Yambo. All rights reserved.
//

import UIKit

class PronounceableViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordLength: UISlider!
    @IBOutlet weak var spacesButton: UIButton!
    @IBOutlet weak var charactersButton: UIButton!
    @IBOutlet weak var symbolsButton: UIButton!
    @IBOutlet weak var hyphenButton: UIButton!
    @IBOutlet weak var numbersButton: UIButton!
    @IBOutlet weak var noneButton: UIButton!
    var buttons = [UIButton]()
    var factory = PasswordFactory()
    var separator: Int = 201

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        buttons = [
            spacesButton,
            charactersButton,
            symbolsButton,
            hyphenButton,
            numbersButton,
            noneButton
        ]
        changeSeparator(hyphenButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeLength(sender: AnyObject) {
        generatePassword()
    }
    @IBAction func changeSeparator(sender: AnyObject) {
        for button in buttons {
            if button.isEqual(sender) {
                button.selected = true
                button.highlighted = true
                separator = button.tag
            } else {
                button.selected = false
                button.highlighted = false
            }
        }
        generatePassword()
    }
    func generatePassword() {
        factory.passwordLength = UInt(passwordLength.value)
        passwordField.text = factory.generatePronounceableWithSeparatorType(Int32(separator))
        
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
