//
//  PasswordsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PasswordsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, PickerViewControllerDelegate  {


    @IBOutlet weak var lengthDisplay: UILabel!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var useSymbolsSwitch: UISwitch!
    @IBOutlet weak var avoidAmbiguousSwitch: UISwitch!
    @IBOutlet weak var useNumbersSwitch: UISwitch!
    @IBOutlet weak var useEmojiSwitch: UISwitch!
    @IBOutlet weak var caseTypeButton: UIButton!
    @IBOutlet weak var separatorTypeButton: UIButton!
    
    let c = PFConstants.instance
    let d = DefaultsManager.get()!
    let f = PasswordFactory.get()!
    var passwordViewController: UIViewController?
    var passwordType: PFPasswordType?
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
        let typeName = c.getNameFor(type: type)
        let storyboardIdentfier = typeName + "Password"
        passwordViewController = storyboard?.instantiateViewController(withIdentifier: storyboardIdentfier)
        self.view = passwordViewController?.view
    }
    func selectedItem(type: PickerTypes, index: Int) {
        switch (type) {
        case .CaseType:
            let ct = c.getCaseType(by: UInt(index))
            self.caseTypeButton.setTitle(c.caseTypes[ct] ?? "", for: .normal)
        case .SeparatorType:
            print ("sep")
            let st = c.getSeparatorType(by: UInt(index))
            self.separatorTypeButton.setTitle(c.separatorTypes[st] ?? "", for: .normal)
        case .PasswordType:
            print("password")
//            newLabel = "PASSWORD TYPE"
        }
        
    }
    func openPickerView(type: PickerTypes) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PickerView") as? PickerViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.setType(type: type)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    @IBAction func selectCaseType(_ sender: UIButton) {
        openPickerView(type: .CaseType)
    }
    
    @IBAction func selectSeparatorType(_ sender: Any) {
        openPickerView(type: .SeparatorType)
    }
    func setupLengthSlider() {
        lengthSlider.minimumValue = 5.0
        lengthSlider.maximumValue = d.float(forKey: "maxPasswordLength")
        lengthSlider.setValue(d.float(forKey: "passwordLength"), animated: false)
    }
    func lengthChanged() {
        let length = Int(lengthSlider.value)
        lengthDisplay.text = "\(length)"
    }
    @IBAction func changeLengthSlider(_ sender: UISlider) {
        lengthChanged()
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
