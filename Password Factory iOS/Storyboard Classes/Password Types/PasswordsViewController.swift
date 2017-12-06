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
    @IBOutlet weak var separatorTypeView: UIView!
    @IBOutlet weak var caseTypeView: UIView!
    
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

    func setupSelectorView(selectorType: PickerTypes, typeView: UIView) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SelectTypes") as? SelectTypesViewController {
            vc.pickerType = selectorType
            typeView.removeSubviews()
            typeView.addSubview(vc.view)
            addChildViewController(vc)
        }
    }
    func selectedItem(type: PickerTypes, index: Int) {
        switch (type) {
        case .CaseType:
            let ct = c.getCaseType(by: UInt(index))
            self.caseTypeButton.setTitle(c.caseTypes[ct] ?? "", for: .normal)
        case .SeparatorType:
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
            vc.setType(type: type,passwordType: passwordType)
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
    func setSwitch(s: UISwitch, defaultsKey:String) {
        s.setOn(d.bool(forKey: defaultsKey), animated: false)
    }
    func setupLengthSlider() {
        lengthSlider.minimumValue = 5.0
        lengthSlider.maximumValue = d.float(forKey: "maxPasswordLength")
        lengthSlider.setValue(d.float(forKey: "passwordLength"), animated: false)
    }
    func setupCaseType() {
        guard let typeName = c.passwordTypes[passwordType]?.lowercased() else {
            return
        }
        let caseTypeKey = "\(typeName)CaseTypeIndex"
        let caseType = c.getCaseType(by: UInt(d.integer(forKey: caseTypeKey)))
        caseTypeButton.setTitle(c.caseTypes[caseType], for: .normal)
        
    }
    func setupSeparatorType() {
        guard let typeName = c.passwordTypes[passwordType]?.lowercased() else {
            return
        }
        let separatorTypeKey = "\(typeName)SeparatorTypeIndex"
        let separatorType = c.getSeparatorType(by: UInt(d.integer(forKey: separatorTypeKey)))
        separatorTypeButton.setTitle(c.separatorTypes[separatorType], for: .normal)
    }
    
    func lengthChanged() {
        let length = Int(lengthSlider.value)
        lengthDisplay.text = "\(length)"
        d.setInteger(Int(lengthSlider.value), forKey: "passwordLength")
    }
    @IBAction func changeLengthSlider(_ sender: UISlider) {
        lengthChanged()
    }
    @IBAction func changeSwitch(_ sender: UISwitch) {
        guard var desc = sender.accessibilityLabel else {
            return
        }
        guard let typeName = c.passwordTypes[passwordType]?.lowercased() else {
            return
        }
        desc = typeName + desc.replacingOccurrences(of: " ", with: "")
        d.setBool(sender.isOn, forKey: desc)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    
}
