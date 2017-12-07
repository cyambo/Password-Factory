//
//  TypeIcons.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

class TypeIcons: NSObject {
    static func getTypeIcon(type :PFPasswordType, andColor color: UIColor) -> UIImage {
        switch(type) {
        case .randomType:
            return StyleKit.imageOfRandomType(typeColor: color)
        case .patternType:
            return StyleKit.imageOfPatternType(typeColor: color)
        case .passphraseType:
            return StyleKit.imageOfPassphraseType(typeColor: color)
        case .pronounceableType:
            return StyleKit.imageOfPronounceableType(typeColor: color)
        case .advancedType:
            return StyleKit.imageOfAdvancedType(typeColor: color)
        case .storedType:
            return StyleKit.imageOfStoredType(typeColor: color)
        }
    }
    static func getTypeIcon(type :PFPasswordType) -> UIImage {
        let c = UIColor.init(red: 0.31, green: 0.678, blue: 0.984, alpha: 1.0)
        return TypeIcons.getTypeIcon(type: type, andColor: c)
    }
    static func drawTypeIcon(type :PFPasswordType, frame: CGRect, color: UIColor) {
        switch(type) {
        case .randomType:
            StyleKit.drawRandomType(frame: frame, resizing: .aspectFit, typeColor: color)
        case .patternType:
            StyleKit.drawPatternType(frame: frame, resizing: .aspectFit, typeColor: color)
        case .passphraseType:
            StyleKit.drawPassphraseType(frame: frame, resizing: .aspectFit, typeColor: color)
        case .pronounceableType:
            StyleKit.drawPronounceableType(frame: frame, resizing: .aspectFit, typeColor: color)
        case .advancedType:
            StyleKit.drawAdvancedType(frame: frame, resizing: .aspectFit, typeColor: color)
        case .storedType:
            StyleKit.drawStoredType(frame: frame, resizing: .aspectFit, typeColor: color)
        }
    }
    func getCaseTypeIcon(type: PFCaseType) -> UIImage {
        switch type {
        case .lowerCase:
            return StyleKit.imageOfLowercase
        case .upperCase:
            return StyleKit.imageOfUppercase
        case .mixedCase:
            return StyleKit.imageOfMixedCase
        case .titleCase:
            return StyleKit.imageOfTitleCase
        }
    }
}
