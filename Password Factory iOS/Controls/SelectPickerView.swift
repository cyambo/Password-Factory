//
//  SelectPickerView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/10/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class SelectPickerView: UIView, PickerViewControllerDelegate {
    @IBInspectable public var pickerTypeString: String?
    @IBInspectable public var passwordTypeInt: Int = 401
    
    let controlLabel = UILabel.init()
    let controlButton = UIButton.init()
    
    let d = DefaultsManager.get()!
    let c = PFConstants.instance
    
    var pickerType: PickerTypes?
    var passwordType: PFPasswordType?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        removeSubviewsAndConstraints()
        addSubview(controlButton)
        addSubview(controlLabel)
        controlButton.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if (pickerTypeString != nil) {
            pickerType = PickerTypes(rawValue: pickerTypeString!)
        }
        passwordType = PFPasswordType.init(rawValue: passwordTypeInt)
        setupView()
    }
    
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
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[label(==125)]-8-[button]-8-|", options: [], metrics: nil, views: views))

        Utilities.centerViewVerticallyInContainer(controlLabel, superview: self)
        Utilities.centerViewVerticallyInContainer(controlButton, superview: self)

        
    }
    func setLabelText() {
        if let pt = pickerType {
            switch pt {
            case .CaseType:
                controlLabel.text = "Case Type:"
            case .SeparatorType:
                controlLabel.text = "Separator Type:"
            case .PasswordType:
                controlLabel.text = "Source Type:"
            }
        }
    }
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
    func setupPasswordtype() {
        guard let passwordTypeKey = getDefaultsKey() else {
            return
        }
        let buttonPasswordType = c.getPasswordType(by: UInt(d.integer(forKey: passwordTypeKey)))
        controlButton.setTitle(c.passwordTypes[buttonPasswordType], for: .normal)

    }
    func setupCaseType() {
        guard let caseTypeKey = getDefaultsKey() else {
            return
        }
        guard let pt = passwordType else {
            return
        }
        var index = d.integer(forKey: caseTypeKey)
        var title = ""
        if pt == .advancedType {
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
    func setupSeparatorType() {
        guard let separatorTypeKey = getDefaultsKey() else {
            return
        }
        let separatorType = c.getSeparatorType(by: UInt(d.integer(forKey: separatorTypeKey)))
        controlButton.setTitle(c.separatorTypes[separatorType], for: .normal)
    }
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
            parentViewController?.present(vc, animated: true, completion: nil)
        }
    }
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
