//
//  StepperView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class StepperView: UIView {
    @IBInspectable public var defaultsKey: String?
    @IBInspectable public var label: String?
    @IBInspectable public var minValue: Int = 0
    @IBInspectable public var maxValue: Int = 100
    @IBInspectable public var stepValue: Int = 1
    let controlStepper = UIStepper.init()
    let controlLabel = UILabel.init()
    let valueLabel = UILabel.init()
    let d = DefaultsManager.get()!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        removeSubviewsAndConstraints()
        addSubview(controlStepper)
        addSubview(controlLabel)
        addSubview(valueLabel)
    }
    override func prepareForInterfaceBuilder() {
        setupView()
    }
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setupView()
    }
    
    func setupView() {

        let views = ["stepper" : controlStepper as UIView, "label" : controlLabel as UIView,"value" : valueLabel as UIView, "superview" : self]
        translatesAutoresizingMaskIntoConstraints = false
        controlStepper.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        let hc = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[label]-8-[stepper(==94)]-8-[value(==29)]-8-|", options: [], metrics: nil, views: views)
        //magic constraints for vertical center
        let vc = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-(<=1)-[label]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        let vc2 = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-(<=1)-[stepper]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)
        let vc3 = NSLayoutConstraint.constraints(withVisualFormat: "H:[superview]-(<=1)-[value(==29)]", options: NSLayoutFormatOptions.alignAllCenterY, metrics: nil, views: views)

        addConstraints(hc)
        addConstraints(vc)
        addConstraints(vc2)
        addConstraints(vc3)
        controlStepper.minimumValue = Double(minValue)
        controlStepper.maximumValue = Double(maxValue)
        controlStepper.stepValue = Double(stepValue)
        valueLabel.backgroundColor = window?.tintColor
        valueLabel.textColor = UIColor.white
        valueLabel.textAlignment = .center
        
        setLabel()
        if defaultsKey != nil {
            controlStepper.value = Double(d.integer(forKey: defaultsKey))
            controlStepper.addTarget(self, action: #selector(changeStepper), for: .valueChanged)
        }
    }
    func setLabel() {
        controlLabel.text = label
        if defaultsKey != nil {
            valueLabel.text = "\(d.integer(forKey: defaultsKey))"
        } else {
            valueLabel.text = "--"
        }
    }
    @objc func changeStepper() {
        d.setInteger(Int(controlStepper.value), forKey: defaultsKey)
        setLabel()
    }

}
