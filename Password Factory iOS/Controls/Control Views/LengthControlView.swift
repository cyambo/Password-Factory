//
//  LengthControlView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// Displays a slider and label with value of slider
class LengthControlView: ControlView {
    let slider = UISlider.init()
    let sizeLabel = UILabel.init()
    
    /// Adds the slider label and size to the view
    override func addViews() {
        super.addViews()
        addSubview(slider)
        addSubview(controlLabel)
        addSubview(sizeLabel)
    }
    /// Positions the views in the container
    override func setupView() {
        super.setupView()
        setupLengthSlider()
        lengthChanged()
        controlLabel.text = "Length"
        sizeLabel.textAlignment = .right
        sizeLabel.font = UIFont.systemFont(ofSize: 32)
        let views = ["slider" : slider as UIView, "label" : controlLabel as UIView, "sizeLabel": sizeLabel as UIView]
        let constraints = ["H:|-[slider]-|",
                           "H:|-[label]-0-[sizeLabel]-|",
                           "V:|-[slider]-4-[sizeLabel(==30)]"]
        addVFLConstraints(constraints: constraints, views: views)
        equalAttributesTo(sizeLabel, controlLabel, attribute: .width)
        equalAttributesTo(sizeLabel, controlLabel, attribute: .height)
        equalAttributesTo(sizeLabel, controlLabel, attribute: .centerY)

    }
    /// Sets up the length slider with the maximum value and moves the knob to the defaults value
    func setupLengthSlider() {
        slider.addTarget(self, action: #selector(changeLengthSlider(_:)), for: .valueChanged)
        slider.minimumValue = 5.0
        slider.maximumValue = d.float(forKey: "maxPasswordLength")
        slider.setValue(d.float(forKey: "passwordLength"), animated: false)
    }
    
    /// Called when length is changed - sets defaults and label
    func lengthChanged() {
        let length = Int(slider.value)
        sizeLabel.text = "\(length)"
        d.setInteger(Int(slider.value), forKey: "passwordLength")
    }
    
    /// action when length is changed
    ///
    /// - Parameter sender: default sender
    @IBAction func changeLengthSlider(_ sender: UISlider) {
        lengthChanged()
    }
    

    
}
