//
//  LengthControlView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
@IBDesignable
class LengthControlView: UIView {
    let slider = UISlider.init()
    let label = UILabel.init()
    let sizeLabel = UILabel.init()
    let d = DefaultsManager.get()!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addViews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLengthSlider()
        lengthChanged()
        setupView()
    }
    
    /// Adds the slider label and size to the view
    func addViews() {
        addSubview(slider)
        addSubview(label)
        addSubview(sizeLabel)
    }
    /// Positions the views in the container
    func setupView() {
        label.text = "Length"
        sizeLabel.textAlignment = .right
        sizeLabel.font = UIFont.systemFont(ofSize: 32)
        let views = ["slider" : slider as UIView, "label" : label as UIView, "sizeLabel": sizeLabel as UIView]
        translatesAutoresizingMaskIntoConstraints = false
        slider.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false

        addConstraint(NSLayoutConstraint.init(item: label, attribute: .width, relatedBy: .equal, toItem: sizeLabel, attribute: .width, multiplier: 1, constant: 1))
        addConstraint(NSLayoutConstraint.init(item: label, attribute: .height, relatedBy: .equal, toItem: sizeLabel, attribute: .height, multiplier: 1, constant: 1))
        addConstraint(NSLayoutConstraint.init(item: label, attribute: .centerY, relatedBy: .equal, toItem: sizeLabel, attribute: .centerY, multiplier: 1, constant: 1))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[slider]-0-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label]-0-[sizeLabel]-0-|", options: [], metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[slider]-4-[sizeLabel(==30)]", options: [], metrics: nil, views: views))
        
    }    /// Sets up the length slider with the maximum value and moves the knob to the defaults value
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
