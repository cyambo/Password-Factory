//
//  SelectPickerView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/10/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Adds a view that has a label and a button to show the picker types view
class SelectPickerView: ControlView, PickerViewControllerDelegate {
    @IBInspectable public var pickerTypeString: String = "Case" //Picker type to use
    @IBInspectable public var passwordTypeInt: Int = 401 //Password type of item

    let controlButton = UIButton.init()
    
    var pickerType: PickerTypes?
    var passwordType: PFPasswordType?
    var currentIndex: Int = -1
    
    override var defaultsKey: String? {
        get {
            return getDefaultsKey()
        }
        set {
            self.defaultsKey = newValue
        }
    }
    
    override func awakeFromNib() {
        pickerType = PickerTypes(rawValue: pickerTypeString) ?? .CaseType
        passwordType = PFPasswordType.init(rawValue: passwordTypeInt)
    }
    
    override func addViews() {
        super.addViews()
        addSubview(controlButton)
        addSubview(controlLabel)
        //sets button action
        controlButton.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
    }
    
    /// Positions the views in the container
    override func setupView() {
        super.setupView()
        if let key = getDefaultsKey() {
            currentIndex = d.integer(forKey: key)
            currentValue = currentValue
        }
        controlButton.roundCorners()
        controlButton.backgroundColor = PFConstants.tintColor
        controlButton.setTitleColor(UIColor.white, for: .normal)
        setButtonText()
        setLabelText()

        let views = ["button" : controlButton as UIView, "label" : controlLabel as UIView]
        addVFLConstraints(constraints: ["H:|-[label(==125)]-8-[button]-|","V:[button(==29)]"], views: views)
        centerViewVertically(controlLabel)
        centerViewVertically(controlButton)
        translatesAutoresizingMaskIntoConstraints = false

        controlButton.titleLabel?.font = PFConstants.labelFont
    }
    
    /// Sets the label based upon PickerType
    func setLabelText() {
        if let pt = pickerType {
            switch pt {
            case .CaseType:
                controlLabel.text = NSLocalizedString("casePickerLabel", comment: "Case")
            case .SeparatorType:
                controlLabel.text = NSLocalizedString("separatorPickerLabel", comment: "Separator")
            case .PasswordType:
                controlLabel.text = NSLocalizedString("sourcePickerLabel", comment: "Source")
            case .NumberType:
                controlLabel.text = NSLocalizedString("rangePickerLabel", comment: "Range")
                
            }
        }
    }
    
    /// Sets the button text, which displays
    func setButtonText() {
        if let pt = pickerType {
            switch pt {
            case .CaseType:
                setupCaseType()
            case .SeparatorType:
                setupSeparatorType()
            case .PasswordType:
                setupPasswordtype()
            case .NumberType:
                setupNumberType()
            }
        }
    }
    
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        controlButton.isEnabled = enabled
    }
    
    /// Sets the button title to the selected number
    func setupNumberType() {
        guard let numberTypeKey = getDefaultsKey() else {
            return
        }
        currentValue = d.integer(forKey: numberTypeKey)
        controlButton.setTitle("\(d.integer(forKey: numberTypeKey))", for: .normal)
    }
    
    /// sets the title if we are the password type
    func setupPasswordtype() {
        guard let passwordTypeKey = getDefaultsKey() else {
            return
        }
        currentValue = d.integer(forKey: passwordTypeKey)
        let buttonPasswordType = c.getPasswordType(by: UInt(d.integer(forKey: passwordTypeKey)))
        controlButton.setTitle(c.passwordTypes[buttonPasswordType], for: .normal)
    }
    
    /// sets the title if we are the case type
    func setupCaseType() {
        guard let caseTypeKey = getDefaultsKey() else {
            return
        }
        guard let pt = passwordType else {
            return
        }
        var index = d.integer(forKey: caseTypeKey)
        currentValue = index
        var title = ""
        if pt == .advancedType { //advanced starts with No Change and doesn't have title case
            index = index - 1
        }
        if index < 0 {
            title = NSLocalizedString("noChangeMessage", comment: "No Change")
        } else {
            let caseType = c.getCaseType(by: UInt(index))
            title = c.caseTypes[caseType] ?? "--"
        }
        controlButton.setTitle(title, for: .normal)
    }
    
    /// sets the title if we are the separator type
    func setupSeparatorType() {
        guard let separatorTypeKey = getDefaultsKey() else {
            return
        }
        currentValue = d.integer(forKey: separatorTypeKey)
        let separatorType = c.getSeparatorType(by: UInt(d.integer(forKey: separatorTypeKey)))
        controlButton.setTitle(c.separatorTypes[separatorType], for: .normal)
    }
    
    /// Gets the defaults key
    ///
    /// - Returns: defaults key to use
    func getDefaultsKey() ->String? {
        guard let pt = passwordType else {
            return nil
        }
        guard let typeName = c.passwordTypes[pt]?.lowercased() else {
            return nil
        }
        guard let pick = pickerType else {
            return nil
        }
        var suffix = ""

        switch pick {
        case .CaseType:
            suffix = "CaseTypeIndex"
        case .SeparatorType:
            suffix = "SeparatorTypeIndex"
        case .PasswordType:
            suffix = "SourceIndex"
        case .NumberType:
            suffix = "SelectedNumber"
        }
        return "\(typeName)\(suffix)"
    }

    /// Opens the picker view
    @objc func openPicker() {
        guard let pass = passwordType else {
            return
        }
        guard let pick = pickerType else {
            return
        }
        if let p = parentViewController {
            Utilities.displayPicker(source: controlButton, delegate: self, parentViewController: p, type: pick, passwordType: pass)
        }
    }
    
    /// Delegate method for PickerViewController - sets defaults and title of button
    ///
    /// - Parameters:
    ///   - type: type of picker
    ///   - index: index of selection
    func selectedItem(type: PickerTypes, index: Int) {
        currentIndex = index
        if let key = getDefaultsKey() {
            d.setInteger(index, forKey: key)
        }
        updateSelection(index: index)
    }
    
    func updateSelection(index: Int) {
        var t = "--"
        var i = index
        guard let type = pickerType else { return }
        switch (type) {
        case .CaseType:
            if passwordType! == .advancedType {
                i = i - 1
            }
            if i < 0 {
                t = NSLocalizedString("noChangeMessage", comment: "No Change")
            } else {
                t = c.caseTypes[c.getCaseType(by: UInt(i))] ?? t
            }
            
        case .SeparatorType:
            t = c.separatorTypes[c.getSeparatorType(by: UInt(i))] ?? t
        case .PasswordType:
            t = c.passwordTypes[c.getPasswordType(by: UInt(i))] ?? t
        case .NumberType:
            t = "\(i)"
        }
        if let key = getDefaultsKey() {
            
            delegate?.controlChanged(controlButton, defaultsKey: key)
        }
        controlButton.setTitle(t, for: .normal)
    }
    override func updateFromObserver(change: Any?) {
        guard let ch = change as? Int else { return }
        currentValue = ch
        if ch != currentIndex {
            currentIndex = ch
            updateSelection(index: ch)
        }

        
        
    }
    /// Overriding this because the tint color changes when a popover happens
    override func tintColorDidChange() {
        super.tintColorDidChange()
        controlButton.backgroundColor = tintColor
    }

}
