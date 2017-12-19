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
        let highlighted = NSMutableAttributedString()
        let defaultColor = ColorUtilities.getDefaultsColor("defaultTextColor")
        for index in password.indices {
            var color = defaultColor
            let char = password[index]
            let s = String(describing:char)
            if (s.count == 1) {
                color = ColorUtilities.getPasswordTextColor(s)
            }
            let attrs = [
                NSAttributedStringKey.foregroundColor:color as Any,
                NSAttributedStringKey.font: font
            ]
            let hChar = NSAttributedString.init(string: s, attributes: attrs)
            highlighted.append(hChar)
        }
        return highlighted
    }
    
    /// Gets the non-highlighted string using the font and default color
    ///
    /// - Parameters:
    ///   - s: string to highlight
    ///   - font: font to use
    /// - Returns: attributed string in font and default color
    public class func getNonHighlightedString(s: String, font: UIFont) ->NSAttributedString {
        let h = NSMutableAttributedString.init(string: s)
        let attrs = [
            NSAttributedStringKey.foregroundColor:ColorUtilities.getDefaultsColor("defaultTextColor") as Any,
            NSAttributedStringKey.font: font
        ]
        h.setAttributes(attrs, range: NSMakeRange(0, s.count))
        return h
    }

}
