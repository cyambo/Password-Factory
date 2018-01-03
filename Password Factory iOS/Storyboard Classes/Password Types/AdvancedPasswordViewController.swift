//
//  AdvancedPasswordViewController.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit
/// Controller for advanced passwords
class AdvancedPasswordViewController: PasswordsViewController {

    @IBOutlet weak var prefixPatternView: TextFieldView!
    @IBOutlet weak var suffixPatternView: TextFieldView!
    @IBOutlet weak var findRegexView: TextFieldView!
    @IBOutlet weak var replacePatternView: TextFieldView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        //set keyboard observers
        nc.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        nc.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        //moving the view to keep the text fields visible
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        let keyboardOrigin = stackView.convert(keyboardViewEndFrame.origin, to: scrollView)

        if let fr = getFirstResponderView() {
            var yPos: CGFloat = 0.0
            if notification.name == Notification.Name.UIKeyboardWillHide {
                //move first responder back to bottom, only if the stackview does not fit in the scrollview
                if stackView.frame.size.height >= scrollView.frame.size.height {
                   yPos = (fr.frame.origin.y + fr.frame.height) - keyboardViewEndFrame.size.height
                }
            } else if notification.name == Notification.Name.UIKeyboardWillChangeFrame {
                //only scroll if the keyboard obscures the view
                if keyboardOrigin.y < scrollView.frame.height {
                    //if the keyboard is shown , scroll the first responder view into frame
                    yPos = (fr.frame.origin.y + fr.frame.height) - keyboardOrigin.y
                }
            }
            //don't scroll where the stack view starts below the top
            if yPos < 0 {
                yPos = 0
            }
            
            let scrollPoint = CGPoint.init(x: 0.0, y:yPos)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }

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
