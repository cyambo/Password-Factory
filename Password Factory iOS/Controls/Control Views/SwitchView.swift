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

    var touchGesture: UITapGestureRecognizer? //tap gesture recognizer that fills the view and toggles the switch
    let controlSwitch = UISwitch.init()

    override func initializeControls() {
        super.initializeControls()
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

        let views = ["switch" : controlSwitch as UIView, "label" : controlLabel as UIView]
        addVFLConstraints(constraints: ["H:|-[label]-8-[switch(==52)]-|"], views: views)
        centerViewVertically(controlLabel)
        centerViewVertically(controlSwitch)
        
        //sets the state and action for the switch
        if let key = defaultsKey {
            controlSwitch.setOn((d.bool(forKey: key)), animated: false)
            controlSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
        }
    }
    
    /// sets defaults for the switch state
    @objc func changeSwitch() {
        if let key = defaultsKey {
            d.setBool(controlSwitch.isOn, forKey: key)
            delegate?.controlChanged(controlSwitch, defaultsKey: key)
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
