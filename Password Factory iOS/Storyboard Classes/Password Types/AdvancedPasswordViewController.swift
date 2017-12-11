//
//  AdvancedPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class AdvancedPasswordViewController: PasswordsViewController {

    @IBOutlet weak var prefixPatternView: TextFieldView!
    @IBOutlet weak var suffixPatternView: TextFieldView!
    @IBOutlet weak var findRegexView: TextFieldView!
    @IBOutlet weak var replacePatternView: TextFieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        nc.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    //moving the view to keep the text fields visible
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let f = view.frame
        guard let fr = getFirstResponderView() else {
            return
        }
        guard let frOrigin = view?.convert(fr.frame.origin, to: view.superview) else {
            return
        }
        guard let keyboardOrigin = view?.convert(keyboardViewEndFrame.origin, to: view.superview) else {
            return
        }
        guard  var p = view.superview?.frame.height else {
            return
        }
        p = (p - view.frame.height) / 2
        var ypos: CGFloat = 0.0
        //TODO: fix when someone clicks on text field when keybaord already is there
        if notification.name == Notification.Name.UIKeyboardWillHide {
            ypos = p
        } else if notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            
            ypos = keyboardOrigin.y - (fr.frame.origin.y + fr.frame.height + p)
        }
        view.frame = CGRect.init(x: f.origin.x, y: ypos, width: f.size.width, height: f.size.height)
 
    }
    func getFirstResponderView() -> UIView? {
        if (prefixPatternView.controlText.isFirstResponder) {
            return prefixPatternView
        }
        if (suffixPatternView.controlText.isFirstResponder) {
            return suffixPatternView
        }
        if (findRegexView.controlText.isFirstResponder) {
            return findRegexView
        }
        if (replacePatternView.controlText.isFirstResponder) {
            return replacePatternView
        }
        return nil
    }


}
