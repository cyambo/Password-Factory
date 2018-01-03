//
//  TextFieldView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/9/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Adds a text field and label to a view connected to defaults
class TextFieldView: ControlView, UITextFieldDelegate {
    
    let controlText = UITextField.init()
    var prevChange : String? = nil
    override func addViews() {
        super.addViews()
        addSubview(controlText)
        addSubview(controlLabel)
        
    }
    /// sets the position of the views and adds observers for the text field
    override func setupView() {
        super.setupView()
        setupTextField()
        controlText.borderStyle = .roundedRect
        controlText.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        
        let views = ["text" : controlText as UIView, "label" : controlLabel as UIView]
        addVFLConstraints(constraints: ["H:|-[label(==125)]-8-[text]-|"], views: views)
        centerViewVertically(controlLabel)
        centerViewVertically(controlText)

        setTextFieldFromDefaults()
        let n = NotificationCenter.default
        n.addObserver(self, selector: #selector(textChanged), name: .UITextFieldTextDidChange, object: controlText)
        controlText.font = PFConstants.labelFont
        setupAccessoryView()
    }
    
    /// Creates the keyboard accessory view that contains the left and right arrows to select items in the control group
    func setupAccessoryView() {
        if controlGroup != nil {
            let accessory = UIView.init(frame: CGRect.init(x: 0, y: 0, width: frame.size.width, height: 44))
            accessory.backgroundColor = UIColor(red:0.73, green:0.75, blue:0.78, alpha:1.0)
            let leftButton = UIButton.init()
            leftButton.setImage(StyleKit.imageOfLeftArrow(strokeColor: UIColor.white), for: .normal)
            leftButton.addTarget(self, action: #selector(goToPreviousItemInControlGroup), for: .touchUpInside)
            let rightButton = UIButton.init()
            rightButton.setImage(StyleKit.imageOfRightArrow(strokeColor: UIColor.white), for: .normal)
            rightButton.addTarget(self, action: #selector(goToNextItemInControlGroup), for: .touchUpInside)
            let doneButton = UIButton.init(type: .system)
            doneButton.setTitle("Done", for: .normal)
            doneButton.setTitleColor(UIColor.white, for: .normal)
            doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
            accessory.addSubview(leftButton)
            accessory.addSubview(rightButton)
            accessory.addSubview(doneButton)
            let aViews = ["left" : leftButton, "right" : rightButton, "done" : doneButton]
            accessory.addVFLConstraints(constraints: ["H:|-[left(==30)]-[right(==30)]","H:[done(==50)]-|","V:[left(==30)]","V:[right(==30)]"], views: aViews)
            accessory.centerViewVertically(leftButton)
            accessory.centerViewVertically(rightButton)
            accessory.centerViewVertically(doneButton)
            controlText.inputAccessoryView = accessory
        }
    }
    @objc func done() {
        controlText.resignFirstResponder()
    }
    /// Selects the controlText item
    override func selectCurrentControlGroupItem() {
        controlText.selectAll(self)
    }
    
    /// Sets the parameters of the text field
    func setupTextField() {
        controlText.autocapitalizationType = .none
        controlText.smartDashesType = .no
        controlText.smartQuotesType = .no
        controlText.smartInsertDeleteType = .no
        controlText.spellCheckingType = .no
        
        //if it is a part of a control group make return a next button
        if controlGroup != nil {
            controlText.returnKeyType = .next
        } else { //otherwise it is a done button
            controlText.returnKeyType = .done
        }
        controlText.clearButtonMode = .always
        controlText.autocorrectionType = .no
        controlText.delegate = self
    }
    
    /// sets the text field with defaults value
    func setTextFieldFromDefaults() {
        guard let dk = defaultsKey else {
            return
        }
        controlText.text = d.string(forKey: dk)
    }
    
    
    /// Control View enable / disable action
    ///
    /// - Parameter enabled: false if disabled
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        controlText.isEnabled = enabled
    }
    
    /// Dismisses the keyboard, or goes to next item in the control group when return key is pressed
    ///
    /// - Parameter textField: default
    /// - Returns: true to return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if controlGroup == nil {
            controlText.resignFirstResponder()
        } else {
            goToNextItemInControlGroup()
        }
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        startAction()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        endAction()
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// Observer method called when text changes
    @objc func textChanged() {
        //do we have anything in the text
        var toChange = ""
        if let s = controlText.text {
            //if we are the find regex
            if defaultsKey == "advancedFindRegex" {
                controlText.textColor = UIColor.black
                //turn the text red if the regex is not valid
                do {
                    _ = try NSRegularExpression(pattern: s, options: .caseInsensitive)
                } catch {
                    controlText.textColor = UIColor.red
                }
            }
            //set the text
            toChange = s
            
        } else {
            //set nothing
            toChange = ""
        }
        if let key = defaultsKey {
            d.setObject(toChange, forKey: key)
            if prevChange != toChange { //don't call the delegate if it is a duplicate
                delegate?.controlChanged(controlText, defaultsKey: key)
            }
        }
        //storing last change to check to see if it is called with the same value twice because of ios bug
        prevChange = toChange
    }
}
