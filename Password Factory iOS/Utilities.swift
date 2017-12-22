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
        passwordString.enumerateSubstrings(in: NSMakeRange(0, passwordString.length), options: .byComposedCharacterSequences, using: {
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

}
