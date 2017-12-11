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

    @objc func adjustForKeyboard(notification: Notification) {
        //moving the view to keep the text fields visible
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let f = view.frame

        guard let keyboardOrigin = view?.convert(keyboardViewEndFrame.origin, to: view.superview) else {
            return
        }
        guard  var p = view.superview?.frame.height else {
            return
        }
        p = (p - view.frame.height) / 2
        var ypos: CGFloat = 0.0
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            ypos = p
        } else if notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            //if we have a first responder in view, then it is the text fields in advanced
            if let fr = getFirstResponderView() {
               ypos = keyboardOrigin.y - (fr.frame.origin.y + fr.frame.height + p)
            } else { //otherwise it is the password field
               ypos = p
            }
            
        }
        view.frame = CGRect.init(x: f.origin.x, y: ypos, width: f.size.width, height: f.size.height)
 
    }
    
    /// Gets the view of the first responder, if it is one of the advanced text fields
    ///
    /// - Returns: view containing the first responder
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
