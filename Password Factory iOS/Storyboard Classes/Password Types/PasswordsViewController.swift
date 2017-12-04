//
//  PasswordsViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class PasswordsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, PickerViewControllerDelegate  {


    @IBOutlet weak var lenghDisplay: UILabel!
    @IBOutlet weak var lengthSlider: UISlider!
    @IBOutlet weak var useSymbolsSwitch: UISwitch!
    @IBOutlet weak var avoidAmbiguousSwitch: UISwitch!
    @IBOutlet weak var useNumbersSwitch: UISwitch!
    @IBOutlet weak var useEmojiSwitch: UISwitch!
    @IBOutlet weak var caseTypeButton: UIButton!
    
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
            self.caseTypeButton.titleLabel?.text = c.caseTypes[ct] ?? ""
        case .SeparatorType:
            print ("sep")
//            let st = c.getSeparatorType(by: UInt(index))
//            newLabel = c.separatorTypes[st] ?? ""
        case .PasswordType:
            print("password")
//            newLabel = "PASSWORD TYPE"
        }
        
    }
    @IBAction func selectCaseType(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "PickerView") as? PickerViewController {

            vc.modalPresentationStyle = .overCurrentContext
            vc.setType(type: .CaseType)
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }

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
