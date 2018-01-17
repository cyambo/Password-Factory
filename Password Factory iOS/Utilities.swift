
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
    
    /// Loads the picker controller from the storyboard
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
    ///   - source: UIView of control that triggered picker
    private class func showPicker(delegate: PickerViewControllerDelegate, pickerViewController: PickerViewController, parentViewController: UIViewController, source: UIView) {
        pickerViewController.delegate = delegate
        _ = pickerViewController.view //load and layout the view
        showPopover(parentViewController: parentViewController, viewControllerToShow: pickerViewController, popoverBounds: pickerViewController.itemPickerView.bounds, source: source)
    }
    
    /// Shows an alert if not hidden
    ///
    /// - Parameters:
    ///   - delegate: alertViewControllerDelegate
    ///   - alertKey: key of alert message
    ///   - parentViewController: parent view controller
    ///   - source: UIView of control that triggered alert
    class func showAlert(delegate: AlertViewControllerDelegate, alertKey: String, parentViewController: UIViewController, disableAlertHiding: Bool, onlyContinue: Bool, source: UIView) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        guard let alertViewController = storyboard.instantiateViewController(withIdentifier: "AlertView") as? AlertViewController else { return }
        alertViewController.delegate = delegate
        alertViewController.disableAlertHiding = disableAlertHiding
        alertViewController.onlyContinue = onlyContinue
        _ = alertViewController.view //load and layout the view
        if !alertViewController.checkIfHidden(alertKeyToShow: alertKey) {
            showPopover(parentViewController: parentViewController, viewControllerToShow: alertViewController, popoverBounds: alertViewController.containerView.bounds, source: source)
        }
    }
    
    /// Shows a viewController as a popover or modal view
    ///
    /// - Parameters:
    ///   - parentViewController: parent view controller of view
    ///   - viewControllerToShow: UIViewController that is displayed in a popover
    ///   - popoverBounds: bounds of popover to show
    ///   - source: UIView of control that triggered popover
    public class func showPopover(parentViewController: UIViewController, viewControllerToShow: PopupViewController, popoverBounds: CGRect, source: UIView, completion: (() ->Void)? = nil) {
        var parent = parentViewController

        //if the parent is PasswordsViewController, use the root view controller
        if parentViewController.isKind(of: PasswordsViewController.self) {
            parent = UIApplication.shared.keyWindow?.rootViewController ?? parentViewController
        }
        //make sure parent is not presenting anything
        guard parent.presentedViewController == nil else { return }
        //set to popover
        viewControllerToShow.screenshot = Utilities.screenshot(parent.view)
        viewControllerToShow.modalPresentationStyle = .popover

        //load the popover
        if let pop = viewControllerToShow.popoverPresentationController {
            pop.permittedArrowDirections = .any
            pop.sourceView = source
            pop.sourceRect = source.bounds
            pop.delegate = viewControllerToShow
            if viewControllerToShow.backgroundColor != nil {
                pop.backgroundColor = viewControllerToShow.backgroundColor
            } else {
                pop.backgroundColor = UIColor.white
            }
            //set the size and bounds
            viewControllerToShow.preferredContentSize = popoverBounds.size
            viewControllerToShow.view.bounds = popoverBounds
        }
        parent.present(viewControllerToShow, animated: true, completion: completion)
    }

    /// Gets a screenshot of the current window
    ///
    /// - Returns: UIImage screenshot
    public class func screenshot(_ viewToScreenShot: UIView? = nil) -> UIImage {
        var currentView = viewToScreenShot
        
        if currentView == nil {
            currentView = UIApplication.shared.keyWindow?.rootViewController?.view
        }
        guard let view = currentView else { return UIImage() }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    /// Gets the side margins for controls which centers and makes the margins bigger them on big screens
    ///
    /// - Returns: margin to use
    public class func getSideMarginsForControls() -> CGFloat {
        var sideMargin : CGFloat =  16.0
        //if the width is greater than 500 then expand the margins
        if let width = UIApplication.shared.keyWindow?.rootViewController?.view.frame.size.width {
            if width > 500.0 {
                sideMargin = (width - 500.0) / 2.0
            }
        }
        return sideMargin
    }
    
    /// Sets the home screen actions from defaults
    public class func setHomeScreenActions() {
        let d = DefaultsManager.get()
        let c = PFConstants.instance
        
        let enabled = d.object(forKey: "enabledHomeScreenItems") as? [Int] ?? [Int]()
        var shortCutItems = [UIApplicationShortcutItem]()
        let enableAdvanced = d.bool(forKey: "enableAdvanced")
        for typeInt in enabled {
            if let passwordType = PFPasswordType.init(rawValue: typeInt) {
                //if advanced is not enabled, and the type is advanced, do not add it
                if passwordType == .advancedType && !enableAdvanced { continue }
                //set the icon
                let icon = UIApplicationShortcutIcon.init(templateImageName: c.getNameFor(type: passwordType))
                //and the action
                let quickAction = UIApplicationShortcutItem(type: "\(typeInt)", localizedTitle: c.getNameFor(type: passwordType), localizedSubtitle: nil, icon: icon, userInfo: nil)
                //add it to the actions
                shortCutItems.append(quickAction)
            }
        }
        //save it
        UIApplication.shared.shortcutItems = shortCutItems
    }
    
    /// Sets the remote store status based on defaults
    public class func setRemoteStore() {
        //load defaults and set keys to not sync
        let d = DefaultsManager.get(PFConstants.instance.disabledSyncKeys, enableShared: false)
        //check to see if iCloud is available, and set the key to enable the sync switch
        let iCloudAvailable = FileManager.default.ubiquityIdentityToken != nil
        d.setBool(iCloudAvailable, forKey: "iCloudIsAvailable")
        //if remote store is set and iCloud is available
        if (iCloudAvailable && d.bool(forKey: "enableRemoteStore")) {
            //register for notifications
            UIApplication.shared.registerForRemoteNotifications()
            //and enable remote kvo store
            d.enableRemoteStore(true)
            
            if d.bool(forKey: "storePasswords") {
                //enable password CloudKit sync
//                PasswordStorage.get().enableRemoteStorage(true)
            }

            //and reset the home screen actions because they may have changed
            setHomeScreenActions()
            
        } else {
            d.setBool(false, forKey: "enableRemoteStore")
            UIApplication.shared.unregisterForRemoteNotifications()
            d.enableRemoteStore(false)
//            PasswordStorage.get().enableRemoteStorage(false)
        }
    }
}
