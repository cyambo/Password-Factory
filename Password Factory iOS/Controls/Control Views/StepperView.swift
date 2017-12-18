//
//  StepperView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Adds a stepper label and value display in a view connected to defaults
class StepperView: ControlView {
    @IBInspectable public var defaultsKey: String? //defaults key to use
    @IBInspectable public var minValue: Int = 0 //minimum value of the stepper
    @IBInspectable public var maxValue: Int = 100 //maximum value of the stepper
    @IBInspectable public var stepValue: Int = 1 //step for each press
    let controlStepper = UIStepper.init()
    let valueLabel = UILabel.init()
    

    override func addViews() {
        super.addViews()
        addSubview(controlStepper)
        addSubview(controlLabel)
        addSubview(valueLabel)
    }
    /// positions the views and sets up the stepper
    override func setupView() {
        super.setupView()
        let views = ["stepper" : controlStepper as UIView, "label" : controlLabel as UIView,"value" : valueLabel as UIView]
        translatesAutoresizingMaskIntoConstraints = false
        controlStepper.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label]-8-[stepper(==94)]-8-[value(==70)]-0-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[value(==29)]", options: [], metrics: nil, views: views))
        Utilities.centerViewVerticallyInContainer(controlLabel, superview: self)
        Utilities.centerViewVerticallyInContainer(controlStepper, superview: self)
        Utilities.centerViewVerticallyInContainer(valueLabel, superview: self)

        controlStepper.minimumValue = Double(minValue)
        controlStepper.maximumValue = Double(maxValue)
        controlStepper.stepValue = Double(stepValue)
        controlStepper.autorepeat = true
        controlStepper.isContinuous = true
        controlStepper.wraps = false
        valueLabel.backgroundColor = Utilities.tintColor
        valueLabel.textColor = UIColor.white
        valueLabel.textAlignment = .center
        Utilities.roundCorners(layer: valueLabel.layer, withBorder: false)
        
        if defaultsKey != nil {
            controlStepper.value = Double(d.integer(forKey: defaultsKey))
            controlStepper.addTarget(self, action: #selector(changeStepper), for: .valueChanged)
        }

        valueLabel.font = Utilities.labelFont
        setStepperLabel()
    }
    
    /// Changes the value label based upon stepper value
    func setStepperLabel() {
        if defaultsKey != nil {
            let val = d.integer(forKey: defaultsKey)
            if val == 0 && defaultsKey == "advancedTruncateAt" {
                valueLabel.text = "None"
            } else {
               valueLabel.text = "\(val)"
            }
            
        } else {
            valueLabel.text = "--"
        }
    }
    
    /// Called when stepper is changed, will set defaults and label
    @objc func changeStepper() {
        d.setInteger(Int(controlStepper.value), forKey: defaultsKey)
        setStepperLabel()
    }

}
