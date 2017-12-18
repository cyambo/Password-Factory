//
//  SwitchView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit


/// View containing a switch and a label connected to defaults
class SwitchView: ControlView {
    @IBInspectable var defaultsKey: String? //defaults key to use

    var touchGesture: UITapGestureRecognizer? //tap gesture recognizer that fills the view and toggles the switch
    let controlSwitch = UISwitch.init()

    override func initializeControls() {
        isUserInteractionEnabled = true
        touchGesture = UITapGestureRecognizer.init(target: self, action: #selector(touched))
        if (touchGesture != nil) {
            addGestureRecognizer(touchGesture!)
        }
    }

    override func addViews() {
        super.addViews()
        addSubview(controlSwitch)
        addSubview(controlLabel)
    }
    /// Adds and positions the switch and label
    override func setupView() {
        super.setupView()
        
        let views = ["switch" : controlSwitch as UIView, "label" : controlLabel as UIView, "superview" : self]
        translatesAutoresizingMaskIntoConstraints = false
        controlSwitch.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[label]-8-[switch(==52)]-0-|", options: [], metrics: nil, views: views))

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
