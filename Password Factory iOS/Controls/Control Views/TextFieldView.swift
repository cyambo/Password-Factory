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
        setupTextField()
    }
    /// sets the position of the views and adds observers for the text field
    override func setupView() {
        super.setupView()
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
            accessory.addSubview(leftButton)
            accessory.addSubview(rightButton)
            let aViews = ["left" : leftButton, "right" : rightButton]
            accessory.addVFLConstraints(constraints: ["H:|-[left(==30)]","H:[right(==30)]-|","V:[left(==30)]","V:[right(==30)]"], views: aViews)
            accessory.centerViewVertically(leftButton)
            accessory.centerViewVertically(rightButton)
            controlText.inputAccessoryView = accessory
        }
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
        controlText.returnKeyType = .done
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
    override func setEnabled(_ enabled: Bool) {
        super.setEnabled(enabled)
        controlText.isEnabled = enabled
    }
    /// Dismisses the keyboard when done is pressed
    ///
    /// - Parameter textField: default
    /// - Returns: true to return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        controlText.resignFirstResponder()
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
