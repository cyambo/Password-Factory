//
//  TextFieldView.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/9/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TextFieldView: UIView, UITextFieldDelegate {
    @IBInspectable public var defaultsKey: String?
    @IBInspectable public var label: String?

    let controlText = UITextField.init()
    let controlLabel = UILabel.init()

    let d = DefaultsManager.get()!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        removeSubviewsAndConstraints()
        addSubview(controlText)
        addSubview(controlLabel)
        setupTextField()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setupView()
    }
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
    func setupView() {
        controlLabel.text = label
        controlText.borderStyle = .roundedRect
        let views = ["text" : controlText as UIView, "label" : controlLabel as UIView]
        translatesAutoresizingMaskIntoConstraints = false
        controlText.translatesAutoresizingMaskIntoConstraints = false
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[label(==125)]-8-[text]-8-|", options: [], metrics: nil, views: views))

        Utilities.centerViewVerticallyInContainer(controlLabel, superview: self)
        Utilities.centerViewVerticallyInContainer(controlText, superview: self)
        let n = NotificationCenter.default
        n.addObserver(self, selector: #selector(textChanged), name: .UITextFieldTextDidChange, object: controlText)
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        controlText.resignFirstResponder()
        return true
    }
    @objc func textChanged() {

        d.setObject(controlText.text, forKey: defaultsKey)
    }
}
