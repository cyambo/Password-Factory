//
//  PickerViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
protocol PickerViewControllerDelegate: class {
    func selectedItem(type: PickerTypes, index: Int)
}

/// Displays a picker view
class PickerViewController: PopupViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var delegate: PickerViewControllerDelegate?
    let c = PFConstants.instance
    var pickerType = PickerTypes.CaseType
    var passwordType = PFPasswordType.randomType
    let d = DefaultsManager.get()
    var lowerRange : UInt = 0
    var upperRange : UInt = 1
    var currentNumber : UInt = 0
    var step : UInt = 1
    var numberTypeTitle = ""
    var isPercent = false
    @IBOutlet weak var itemPickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!

    
    func setType(type: PickerTypes, passwordType: PFPasswordType) {
        pickerType = type
        self.passwordType = passwordType
    }
    
    func setNumberType(title: String, isPercent: Bool, current: UInt, lowerRange l: UInt, upperRange u: UInt, step s: UInt) {
        lowerRange = l
        upperRange = u
        step = s
        currentNumber = current
        if step == 0 { step = 1}
        if upperRange < lowerRange {
            upperRange = lowerRange + step
        }
        pickerType = .NumberType
        numberTypeTitle = title
        self.isPercent = isPercent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var rowToSelect = 0
        if pickerType != .NumberType {
            if let key = getDefaultsKey() {
                rowToSelect = d.integer(forKey: key)
            }
        } else {
            rowToSelect = Int((currentNumber - lowerRange) / step)
        }
        itemPickerView.selectRow(rowToSelect, inComponent: 0, animated: false)
        setupTitle()
    }
    override func viewDidLayoutSubviews() {
        doneButton.addBorder([.top],color: PFConstants.tintColor)
    }
    
    /// Sets the title
    func setupTitle() {
        if pickerType == .PasswordType {
            titleLabel.text = "Password Source"
        } else if pickerType == .NumberType {
            titleLabel.text = numberTypeTitle
        } else {
            titleLabel.text = "Select \(pickerType.rawValue)"
        }
    }
    func getNumberOfSteps() -> Int {
        return Int((upperRange - lowerRange) / step) + 1
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (pickerType) {
        case .CaseType:
            if passwordType == .randomType {
                return c.caseTypes.count - 1
            }
            return c.caseTypes.count
        case .SeparatorType:
            return c.separatorTypes.count
        case .PasswordType:
            return 4
        case .NumberType:
            return getNumberOfSteps()
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch (pickerType) {
        case .CaseType:
            if row == 0 {
                return "No Change"
            } else {
                let ct = c.getCaseType(by: UInt(row - 1))
                return c.caseTypes[ct]
            }

        case .SeparatorType:
            let st = c.getSeparatorType(by: UInt(row))
            return c.separatorTypes[st]
        case .PasswordType:
            let pt = c.getPasswordType(by: UInt(row))
            return c.passwordTypes[pt]
        case .NumberType:
            let val = Int(lowerRange) + (row * Int(step))
            let percent = isPercent ? "%" : ""
            return "\(val)\(percent)"
        }
    }
    
    /// Called when done is pressed, or the background is tapped
    override func done() {
        super.done()
        dismiss(animated: true, completion: nil)
        let selected = itemPickerView.selectedRow(inComponent: 0)
        delegate?.selectedItem(type: pickerType, index: selected)
    }
    
    /// Gets the defaults key to use
    ///
    /// - Returns: defaults key
    func getDefaultsKey() -> String? {
        var pick = pickerType.rawValue + "Type"
        if pickerType == .PasswordType {
            pick = "Source"
        }
        if let pt = c.passwordTypes[passwordType]?.lowercased() {
            return pt + pick + "Index"
        }
        return nil
    }




}
