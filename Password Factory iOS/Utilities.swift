//
//  Utilities.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class Utilities: NSObject {

    
    /// Highlights a password string, or returns it in the default color based upon defaults
    ///
    /// - Parameters:
    ///   - password: password to highlight
    ///   - font: font to use
    /// - Returns: attrbuted string that is highlighted with colors set in prefs
    public class func highlightPassword(password: String, font: UIFont) ->NSAttributedString {
        
        if(DefaultsManager.get().bool(forKey: "colorPasswordText")) {
            //color it
            return Utilities.highlightPasswordString(password: password, font: font)
        } else {
            //don't color it
            return Utilities.getNonHighlightedString(s: password, font: font)
        }
    }
    
    /// Highlights the password string
    ///
    /// - Parameters:
    ///   - password: password to highlight
    ///   - font: font to use
    /// - Returns: attributed string that is highlighted
    class func highlightPasswordString(password: String, font: UIFont) -> NSAttributedString {
        let passwordString = password as NSString
        let highlighted = getNonHighlightedString(s: password, font: font)
        passwordString.enumerateSubstrings(in: NSRange.init(location: 0, length: passwordString.length), options: .byComposedCharacterSequences, using: {
            (substring, substringRange, _, _) in
            if substring?.count == 1 {
                let attrs = [
                    NSAttributedStringKey.foregroundColor:ColorUtilities.getPasswordTextColor(substring) as Any,
                    ]
    
                highlighted.addAttributes(attrs, range: substringRange)
            }
        })
        return highlighted
    }
    
    /// Highlights and dodge color a password
    ///
    /// - Parameters:
    ///   - password: password to highlight
    ///   - font: font to use
    ///   - backgroundColor: background color of view (used for dodge)
    /// - Returns: Dodged color password
    class func dodgeHighlightedPasswordString(password: String, font: UIFont, backgroundColor: UIColor) -> NSAttributedString {
        guard let password = highlightPassword(password: password, font: font).mutableCopy() as? NSMutableAttributedString else {
            return NSAttributedString()
        }
        let passwordString = password.string as NSString
        passwordString.enumerateSubstrings(in: NSRange.init(location: 0, length: passwordString.length), options: .byComposedCharacterSequences, using: {
            (substring, substringRange, _, _) in
            if substring?.count == 1 {
                var effectiveRange = substringRange
                if let textColor = password.attribute(.foregroundColor, at: substringRange.location, effectiveRange: &effectiveRange) as? UIColor {
                    let dodged = ColorUtilities.dodgeColor(textColor, backgroundColor: backgroundColor)
                    let attrs = [
                        NSAttributedStringKey.foregroundColor:dodged as Any,
                        ]
                    password.addAttributes(attrs, range: substringRange)
                }
            }
        })
        return password
        
    }
    
    /// Gets the non-highlighted string using the font and default color
    ///
    /// - Parameters:
    ///   - s: string to highlight
    ///   - font: font to use
    /// - Returns: attributed string in font and default color
    public class func getNonHighlightedString(s: String, font: UIFont) ->NSMutableAttributedString {
        let passwordString = s as NSString
        let h = NSMutableAttributedString.init(string: s)
        let attrs = [
            NSAttributedStringKey.foregroundColor:ColorUtilities.getDefaultsColor("defaultTextColor") as Any,
            NSAttributedStringKey.font: font
        ]
        h.setAttributes(attrs, range: NSMakeRange(0, passwordString.length))
        return h
    }
    
    /// Loads the picker controller from the storyboard//FIXME:
    ///
    /// - Returns: PickerViewController
    private class func loadPickerFromStoryboard() -> (PickerViewController?) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "PickerView") as? PickerViewController
    }
    
    /// Displays the picker controller on screen either in a popover or full screen
    ///
    /// - Parameters:
    ///   - source: view of button clicked
    ///   - delegate: PickerViewControllerDelegate object
    ///   - parentViewController: the parent view controller to display
    ///   - type: PickerType
    ///   - passwordType: PFPasswordType
    public class func displayPicker(source: UIView, delegate: PickerViewControllerDelegate, parentViewController: UIViewController, type: PickerTypes, passwordType: PFPasswordType) {
        guard let vc = loadPickerFromStoryboard() else {
            return
        }
        vc.setType(type: type, passwordType: passwordType)
        showPicker(delegate: delegate, pickerViewController: vc, parentViewController: parentViewController, source: source)
        
    }
    
    /// Displays a number picker
    ///
    /// - Parameters:
    ///   - source: view of button clicked
    ///   - delegate: PickerViewControllerDelegate object
    ///   - parentViewController: the parent view controller to display
    ///   - title: Title of picker
    ///   - isPercent: Is the picker a percent picker
    ///   - current: current number value
    ///   - l: lower value
    ///   - u: upper value
    ///   - s: step value
    public class func displayNumberPicker(source: UIView, delegate: PickerViewControllerDelegate, parentViewController: UIViewController, title: String, isPercent: Bool, current: UInt, lowerRange l: UInt, upperRange u: UInt, step s: UInt) {
        guard let vc = loadPickerFromStoryboard() else {
            return
        }
        vc.setNumberType(title: title, isPercent: isPercent, current: current, lowerRange: l, upperRange: u, step: s)
        vc.delegate = delegate
        showPicker(delegate: delegate, pickerViewController: vc, parentViewController: parentViewController, source: source)
        
    }
    
    /// Private class method to show the picker
    ///
    /// - Parameters:
    ///   - delegate: PickerViewControllerDelegate object
    ///   - pickerViewController: PickerViewController
    ///   - parentViewController: Parent View Controller
    ///   - source: source button
    private class func showPicker(delegate: PickerViewControllerDelegate, pickerViewController: PickerViewController, parentViewController: UIViewController, source: UIView) {
        var pvc = parentViewController
        if parentViewController.isKind(of: PasswordsViewController.self) {
            pvc = UIApplication.shared.keyWindow?.rootViewController ?? parentViewController
        }
        pickerViewController.delegate = delegate
        pickerViewController.modalPresentationStyle = .popover
        if let pop = pickerViewController.popoverPresentationController {
            pop.permittedArrowDirections = .any
            pop.sourceView = source
            pop.sourceRect = source.bounds
            pop.delegate = pickerViewController
            _ = pickerViewController.view //this loads the view and sets sizes
            pickerViewController.preferredContentSize = pickerViewController.itemPickerView.bounds.size
            
            pickerViewController.view.bounds = pickerViewController.itemPickerView.bounds
        }
        pvc.present(pickerViewController, animated: true, completion: nil)
    }
    
    /// Gets a screenshot of the current window
    ///
    /// - Returns: UIImage screenshot
    public class func screenshot() -> UIImage {
        guard let layer = UIApplication.shared.keyWindow?.layer else { return UIImage() }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let currentContext = UIGraphicsGetCurrentContext() else { UIGraphicsEndImageContext(); return UIImage() }
        layer.render(in: currentContext)
        guard let screenshot = UIGraphicsGetImageFromCurrentImageContext() else { UIGraphicsEndImageContext(); return UIImage() }
        UIGraphicsEndImageContext()
        return screenshot
    }

}
