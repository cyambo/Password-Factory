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
    let container = UIView.init()
    /// Adds the slider label and size to the view
    override func addViews() {
        super.addViews()
        addSubview(container)
        container.addSubview(slider)
        container.addSubview(controlLabel)
        container.addSubview(sizeLabel)
    }
    /// Positions the views in the container
    override func setupView() {
        super.setupView()
        setupLengthSlider()
        setActions(slider)
        lengthChanged()
        controlLabel.text = "Length"
        sizeLabel.textAlignment = .right
        sizeLabel.font = UIFont.systemFont(ofSize: 32)
        //set container to height of 65 and to fill horizontally
        addVFLConstraints(constraints: ["H:|-[container]-|", "V:[container(==65)]"], views: ["container" : container])
        
        let views = ["slider" : slider as UIView, "label" : controlLabel as UIView, "sizeLabel": sizeLabel as UIView]
        let constraints = ["H:|-(0)-[slider]-(0)-|",
                           "H:|-(0)-[label]-0-[sizeLabel]-(0)-|",
                           "V:|-(0)-[slider]-4-[sizeLabel(==30)]"]
        container.addVFLConstraints(constraints: constraints, views: views)
        container.equalAttributesTo(sizeLabel, controlLabel, attribute: .width)
        container.equalAttributesTo(sizeLabel, controlLabel, attribute: .height)
        container.equalAttributesTo(sizeLabel, controlLabel, attribute: .centerY)
        centerViewVertically(container)
        
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
        if let key = defaultsKey {
            let length = Int(slider.value)
            sizeLabel.text = "\(length)"
            d.setInteger(Int(slider.value), forKey: key)
        }
    }

    /// action when length is changed
    ///
    /// - Parameter sender: default sender
    @IBAction func changeLengthSlider(_ sender: UISlider) {
        lengthChanged()
    }
    

    
}
