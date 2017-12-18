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
    @IBInspectable public var defaultsKey: String? //defaults key to use

    let controlText = UITextField.init()

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
        addVFLConstraints(constraints: ["H:|-0-[label(==125)]-8-[text]-0-|"], views: views)
        centerViewVertically(controlLabel)
        centerViewVertically(controlText)

        setTextFieldFromDefaults()
        let n = NotificationCenter.default
        n.addObserver(self, selector: #selector(textChanged), name: .UITextFieldTextDidChange, object: controlText)
        controlText.font = PFConstants.labelFont
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
        controlText.delegate = self
    }
    /// sets the text field with defaults value
    func setTextFieldFromDefaults() {
        guard let dk = defaultsKey else {
            return
        }
        controlText.text = d.string(forKey: dk)
    }
    /// Dismisses the keyboard when done is pressed
    ///
    /// - Parameter textField: default
    /// - Returns: true to return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        controlText.resignFirstResponder()
        return true
    }
    
    /// Observer method called when text changes
    @objc func textChanged() {
        //do we have anything in the text
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
            d.setObject(s, forKey: defaultsKey)
        } else {
            //set nothing
            d.setObject("", forKey: defaultsKey)
        }
        
    }
}
