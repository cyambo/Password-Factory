//
//  SelectPickerView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/10/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// Adds a view that has a label and a button to show the picker types view
class SelectPickerView: UIView, PickerViewControllerDelegate {
    @IBInspectable public var pickerTypeString: String? //Picker type to use
    @IBInspectable public var passwordTypeInt: Int = 401 //Password type of item
    
    let controlLabel = UILabel.init()
    let controlButton = UIButton.init()
    
    let d = DefaultsManager.get()!
    let c = PFConstants.instance
    
    var pickerType: PickerTypes?
    var passwordType: PFPasswordType?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addViews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }

        
    override func layoutSubviews() {
        super.layoutSubviews()
        if (pickerTypeString != nil) {
            pickerType = PickerTypes(rawValue: pickerTypeString!)
        }
        passwordType = PFPasswordType.init(rawValue: passwordTypeInt)
        setupView()
    }
    func addViews() {
        addSubview(controlButton)
        addSubview(controlLabel)
        //sets button action
        controlButton.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
    }
    /// Positions the views in the container
    func setupView() {
        Utilities.roundCorners(layer: controlButton.layer, withBorder: false)
        controlButton.backgroundColor = Utilities.tintColor
        controlButton.setTitleColor(UIColor.white, for: .normal)

        setButtonText()
        setLabelText()
        let views = ["button" : controlButton as UIView, "label" : controlLabel as UIView]
        translatesAutoresizingMaskIntoConstraints = false
        controlButton.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label(==125)]-8-[button]-0-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[button(==29)]", options: [], metrics: nil, views: views))

        Utilities.centerViewVerticallyInContainer(controlLabel, superview: self)
        Utilities.centerViewVerticallyInContainer(controlButton, superview: self)
        addBottomBorderWithColor(color: Utilities.cellBorderColor, width: 0.5)
        controlLabel.font = Utilities.labelFont
        controlButton.titleLabel?.font = Utilities.labelFont
        
    }
    
    /// Sets the label based upon PickerType
    func setLabelText() {
        if let pt = pickerType {
            switch pt {
            case .CaseType:
                controlLabel.text = "Case"
            case .SeparatorType:
                controlLabel.text = "Separator"
            case .PasswordType:
                controlLabel.text = "Source"
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
            }
        }

    }
    
    /// sets the title if we are the password type
    func setupPasswordtype() {
        guard let passwordTypeKey = getDefaultsKey() else {
            return
        }
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
        var title = ""
        if pt == .advancedType { //advanced starts with No Change and doesn't have title case
            index = index - 1
        }
        if index < 0 {
            title = "No Change"
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
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "PickerView") as? PickerViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.setType(type: pick,passwordType: pass)
            vc.delegate = self
            if let r = UIApplication.shared.keyWindow?.rootViewController {
                r.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    /// Delegate method for PickerViewController - sets defaults and title of button
    ///
    /// - Parameters:
    ///   - type: type of picker
    ///   - index: index of selection
    func selectedItem(type: PickerTypes, index: Int) {
        var t = "--"
        var i = index
        switch (type) {
        case .CaseType:
            if passwordType! == .advancedType {
                i = i - 1
            }
            if i < 0 {
                t = "No Change"
            } else {
               t = c.caseTypes[c.getCaseType(by: UInt(i))] ?? t
            }
            
        case .SeparatorType:
            t = c.separatorTypes[c.getSeparatorType(by: UInt(i))] ?? t
        case .PasswordType:
            t = c.passwordTypes[c.getPasswordType(by: UInt(i))] ?? t
        }
        if let key = getDefaultsKey() {
            d.setInteger(index, forKey: key)
        }
        controlButton.setTitle(t, for: .normal)
    }

}
