//
//  StepperView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Adds a stepper label and value display in a view connected to defaults
class StepperView: ControlView, PickerViewControllerDelegate {

    @IBInspectable public var minValue: Int = 0 //minimum value of the stepper
    @IBInspectable public var maxValue: Int = 100 //maximum value of the stepper
    @IBInspectable public var stepValue: Int = 1 //step for each press
    @IBInspectable public var isPercent: Bool = false //is it a percent meter
    
    let controlStepper = UIStepper.init()
    let valueLabel = UIButton.init()
    
    override func addViews() {
        super.addViews()
        addSubview(controlStepper)
        addSubview(controlLabel)
        addSubview(valueLabel)
    }
    /// positions the views and sets up the stepper
    override func setupView() {
        super.setupView()
        setActions(controlStepper)
        let views = ["stepper" : controlStepper as UIView, "label" : controlLabel as UIView,"value" : valueLabel as UIView]

        addVFLConstraints(constraints: ["H:|-[label]-8-[stepper(==94)]-8-[value(==70)]-|","V:[value(==29)]"], views: views)
        centerViewVertically(controlLabel)
        centerViewVertically(controlStepper)
        centerViewVertically(valueLabel)

        controlStepper.minimumValue = Double(minValue)
        controlStepper.maximumValue = Double(maxValue)
        controlStepper.stepValue = Double(stepValue)
        controlStepper.autorepeat = true
        controlStepper.isContinuous = true
        controlStepper.wraps = false
        valueLabel.backgroundColor = PFConstants.tintColor
        valueLabel.setTitleColor(UIColor.white, for: .normal)
        valueLabel.roundCorners()
        
        if let key = defaultsKey {
            controlStepper.value = Double(d.integer(forKey: key))
            currentValue = d.integer(forKey: key)
            controlStepper.addTarget(self, action: #selector(changeStepper), for: .valueChanged)
            valueLabel.addTarget(self, action: #selector(loadPicker), for: .touchUpInside)
        }
        valueLabel.titleLabel?.font = PFConstants.labelFont
        setStepperLabel()
    }

    @objc func loadPicker() {
        let pickerTitle = "\(label ?? "Select")"

        if let p = parentViewController {
            Utilities.displayNumberPicker(source: valueLabel, delegate: self, parentViewController: p, title: pickerTitle, isPercent: isPercent, current: UInt(controlStepper.value), lowerRange: UInt(minValue), upperRange: UInt(maxValue), step: UInt(stepValue))
        }
    }
    
    /// Picker View delegate method
    ///
    /// - Parameters:
    ///   - type: picker type
    ///   - index: selected index
    func selectedItem(type: PickerTypes, index: Int) {
        controlStepper.value = Double((stepValue * index) + minValue)
        changeStepper()
    }
    /// Changes the value label based upon stepper value
    func setStepperLabel() {
        if let key = defaultsKey {
            let val = d.integer(forKey: key)
            currentValue = val
            if val == 0 && defaultsKey == "advancedTruncateAt" {
                valueLabel.setTitle("None", for: .normal)
            } else {
                let percent = isPercent ? "%" : ""
                valueLabel.setTitle("\(val)\(percent)", for: .normal)

            }
        } else {
            valueLabel.setTitle("--", for: .normal)
        }
    }
    override func updateFromObserver(change: Any?) {
        guard let ch = change as? Int else { return }
        if controlStepper.value != Double(ch) {
            controlStepper.value = Double(ch)
            currentValue = ch
            changeStepper()
            alertChangeFromiCloud()
        }
    }
    /// Called when stepper is changed, will set defaults and label
    @objc func changeStepper() {
        if let key = defaultsKey {
            d.setInteger(Int(controlStepper.value), forKey: key)
            currentValue = Int(controlStepper.value)
            setStepperLabel()
            delegate?.controlChanged(controlStepper, defaultsKey: key)
        }

    }
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        controlStepper.isEnabled = enabled
        valueLabel.isEnabled = enabled
    }
    override func tintColorDidChange() {
        super.tintColorDidChange()
        valueLabel.backgroundColor = tintColor
    }

}
