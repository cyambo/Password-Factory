//
//  PassphraseViewController.swift
//  Password Factory
//
//  Created by Cristiana Yambo on 12/4/15.
//  Copyright © 2015 Cristiana Yambo. All rights reserved.
//

import UIKit

class PassphraseViewController: UIViewController {


    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordLength: UISlider!
    
    @IBOutlet weak var hyphenButton: UIButton!
    @IBOutlet weak var spaceButton: UIButton!
    @IBOutlet weak var underscoreButton: UIButton!
    @IBOutlet weak var noneButton: UIButton!
    
    
    @IBOutlet weak var lowerCaseButton: UIButton!
    @IBOutlet weak var upperCaseButton: UIButton!
    @IBOutlet weak var titleCaseButton: UIButton!
    @IBOutlet weak var mixedCaseButton: UIButton!
    
    var separatorButtons = [UIButton]()
    var caseButtons = [UIButton]()

    var factory = PasswordFactory()
    
    var separatorType: Int = 301
    var caseType: Int = 401
    
    override func viewDidLoad() {
        super.viewDidLoad()
        separatorButtons = [hyphenButton, spaceButton, underscoreButton, noneButton]
        caseButtons = [lowerCaseButton, upperCaseButton, titleCaseButton, mixedCaseButton]
        changeType(hyphenButton)
        changeType(lowerCaseButton)
        generatePassword()

    }

    @IBAction func changeType(sender: AnyObject) {
        if separatorButtons.contains(sender as! UIButton) {
            separatorType = highlight(separatorButtons, clicked: sender as! UIButton)
        }
        if caseButtons.contains(sender as! UIButton) {
            caseType = highlight(caseButtons, clicked: sender as! UIButton)
        }
        generatePassword()
    }

    @IBAction func changeLength(sender: AnyObject) {
        generatePassword()
    }
    func highlight(buttons: Array<UIButton> ,  clicked:UIButton) -> Int {
        var tag = 0
        for button in buttons {
            if button.isEqual(clicked) {
                button.selected = true
                button.highlighted = true
                tag = button.tag
            } else {
                button.selected = false
                button.highlighted = false
            }
        }
        return tag
    }
    func generatePassword() {
        factory.passwordLength = UInt(passwordLength.value)
        passwordField.text = factory.generatePassphraseWithCode(Int32(separatorType), caseType: Int32(caseType))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
