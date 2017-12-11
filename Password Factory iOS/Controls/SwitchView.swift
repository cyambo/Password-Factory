//
//  SwitchView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// View containing a switch and a label connected to defaults
class SwitchView: UIView {
    @IBInspectable var defaultsKey: String? //defaults key to use
    @IBInspectable var label: String? //label to display

    var touchGesture: UITapGestureRecognizer? //tap gesture recognizer that fills the view and toggles the switch
    let controlSwitch = UISwitch.init()
    let controlLabel = UILabel.init()
    
    let d = DefaultsManager.get()!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isUserInteractionEnabled = true
        touchGesture = UITapGestureRecognizer.init(target: self, action: #selector(touched))
        if (touchGesture != nil) {
            addGestureRecognizer(touchGesture!)
        }
        removeSubviewsAndConstraints()
        addSubview(controlSwitch)
        addSubview(controlLabel)
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setupView()
    }
    
    /// Adds and positions the switch and label
    func setupView() {
        if label != nil {
            controlLabel.text = label
        } else {
            controlLabel.text = "Switch"
        }
        let views = ["switch" : controlSwitch as UIView, "label" : controlLabel as UIView, "superview" : self]
        translatesAutoresizingMaskIntoConstraints = false
        controlSwitch.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[switch(==51)]-(16)-[label]-16-|", options: [], metrics: nil, views: views))

        Utilities.centerViewVerticallyInContainer(controlLabel, superview: self)
        Utilities.centerViewVerticallyInContainer(controlSwitch, superview: self)
        
        //sets the state and action for the switch
        if defaultsKey != nil {
            controlSwitch.setOn((d.bool(forKey: defaultsKey)), animated: false)
            controlSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
        }
    }
    
    /// sets defaults for the switch state
    @objc func changeSwitch() {
        if defaultsKey != nil {
            d.setBool(controlSwitch.isOn, forKey: defaultsKey)
        }
        
    }
    
    /// Called when the view is tapped
    ///
    /// - Parameter recognizer: default
    @objc func touched(recognizer : UITapGestureRecognizer) {
        controlSwitch.setOn(!controlSwitch.isOn, animated: true)
        changeSwitch()
    }
}
