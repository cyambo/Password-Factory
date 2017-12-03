//
//  PasswordsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PasswordsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {

    

    @IBOutlet weak var lenghDisplay: UILabel!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var useSymbolsSwitch: UISwitch!
    @IBOutlet weak var avoidAmbiguousSwitch: UISwitch!
    @IBOutlet weak var useNumbersSwitch: UISwitch!
    @IBOutlet weak var useEmojiSwitch: UISwitch!
    @IBOutlet weak var caseTypePicker: UIPickerView!
    let c = PasswordFactoryConstants.get()!
    let d = DefaultsManager.get()!
    let f = PasswordFactory.get()!
    var passwordViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setup(type: PFPasswordType) {
        let typeName = PasswordFactoryConstants.get().getNameFor(type) ?? "random"
        let storyboardIdentfier = typeName + "Password"
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        passwordViewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentfier)
        self.view = passwordViewController?.view
    }
    @IBAction func changeLengthSlider(_ sender: UISlider) {
    }
    @IBAction func changeSwitch(_ sender: UISwitch) {
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
}
