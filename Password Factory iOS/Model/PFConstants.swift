//
//  PFConstants.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

/// Picker Types that are available
///
/// - CaseType: Select case type
/// - SeparatorType: Select separator type
/// - PasswordType: Select password type
enum PickerTypes: String {
    case CaseType = "Case"
    case SeparatorType = "Separator"
    case PasswordType = "Password"
    case NumberType = "Number"
}

/// Swift version of PasswordFactoryConstants that changes the Any types to specific types
final class PFConstants: NSObject {
    
    static let tintColor = UIColor(red:0.99, green:0.28, blue:0.12, alpha:1.0)
    static let cellBorderColor = UIColor(white: 0.85, alpha: 1.0)
    static let containerBorderColor = UIColor(white: 0.6, alpha: 1.0)
    static let labelFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    
    //not subclassing PasswordFactoryContstants because you cant override the
    //properties with new ones because they are Any!
    static let instance = PFConstants() //access this for singleton
    let c = PasswordFactoryConstants.get()!
    public let phoneticSounds: [String]
    public let phoneticSoundsTwo: [String]
    public let phoneticSoundsThree: [String]
    public let passwordCharacterTypes: [PFCharacterType:String]
    public let passwordTypes: [PFPasswordType:String]
    public let passwordNameToType: [String:PFPasswordType]
    public let caseTypes: [PFCaseType:String]
    public let separatorTypes: [PFSeparatorType:String]
    public let patternCharacterToType: [String:PFPatternTypeItem]
    public let patternTypeToName: [PFPatternTypeItem:String]
    public let patternTypeToCharacter: [PFPatternTypeItem:String]
    public let patternTypeToDescription: [PFPatternTypeItem:String]
    public let passwordTypesIndex: [PFPasswordType]
    public let caseTypeIndex: [PFCaseType]
    public let separatorTypeIndex: [PFSeparatorType]
    public let patternTypeIndex: [PFPatternTypeItem]
    public var escapedSymbols: String = ""
    public var disabledSyncKeys = [String]()
    //init is private for singleton
    private override init() {
        //converting all the arrays and dictionaries to ones with proper types
        //rather than Any?
        
        phoneticSounds = c.phoneticSounds.map { $0 as! String }
        phoneticSoundsTwo = c.phoneticSoundsTwo.map { $0 as! String }
        phoneticSoundsThree = c.phoneticSoundsThree.map { $0 as! String }
        passwordTypesIndex = c.passwordTypesIndex.map { PFPasswordType(rawValue:$0 as! Int)! }
        caseTypeIndex = c.caseTypeIndex.map { PFCaseType(rawValue:$0 as! Int)! }
        separatorTypeIndex = c.separatorTypeIndex.map { PFSeparatorType(rawValue:$0 as! Int)! }
        patternTypeIndex = c.patternTypeIndex.map { PFPatternTypeItem(rawValue:$0 as! Int)! }
        
        passwordCharacterTypes = Dictionary.init(uniqueKeysWithValues: c.passwordCharacterTypes.map {
            key, value in ( PFCharacterType(rawValue:key as! Int)!, value as! String)
        })
        passwordTypes = Dictionary.init(uniqueKeysWithValues: c.passwordTypes.map {
            key, value in ( PFPasswordType(rawValue:key as! Int)!, value as! String)
        })
        passwordNameToType = Dictionary.init(uniqueKeysWithValues: c.passwordNameToType.map {
            key, value in (  key as! String, PFPasswordType(rawValue:value as! Int)!)
        })
        caseTypes = Dictionary.init(uniqueKeysWithValues: c.caseTypes.map {
            key, value in ( PFCaseType(rawValue:key as! Int)!, value as! String)
        })
        separatorTypes = Dictionary.init(uniqueKeysWithValues: c.separatorTypes.map {
            key, value in ( PFSeparatorType(rawValue:key as! Int)!, value as! String)
        })
        patternCharacterToType = Dictionary.init(uniqueKeysWithValues: c.patternCharacterToType.map {
            key, value in (  key as! String, PFPatternTypeItem(rawValue:value as! Int)!)
        })
        patternTypeToName = Dictionary.init(uniqueKeysWithValues: c.patternTypeToName.map {
            key, value in ( PFPatternTypeItem(rawValue:key as! Int)!, value as! String)
        })
        patternTypeToDescription = Dictionary.init(uniqueKeysWithValues: c.patternTypeToDescription.map {
            key, value in ( PFPatternTypeItem(rawValue:key as! Int)!, value as! String)
        })
        patternTypeToCharacter = Dictionary.init(uniqueKeysWithValues: c.patternTypeToCharacter.map {
            key, value in ( PFPatternTypeItem(rawValue:key as! Int)!, value as! String)
        })

        escapedSymbols = c.escapedSymbols
        disabledSyncKeys = c.disabledSyncKeys.map { $0 as! String }
    }

    public func getPasswordType(by: UInt) -> PFPasswordType {
        return c.getPasswordType(by: by)
    }
    public func getCaseType(by: UInt) -> PFCaseType {
        return c.getCaseType(by: by)
    }
    public func getSeparatorType(by: UInt) -> PFSeparatorType {
        return c.getSeparatorType(by: by)
    }
    public func getPatternType(by: UInt) -> PFPatternTypeItem {
        return c.getPatternType(by: by)
    }
    public func getNameFor(type: PFPasswordType) -> String {
        if let s = c.getNameFor(type){
            return s
        }
        return "";
    }
    public func getNameFor(type: PFCaseType) -> String {
        if let s = c.getNameFor(type){
            return s
        }
        return "";
    }
    public func getNameFor(type: PFPatternTypeItem) -> String {
        if let s = c.getNameFor(type){
            return s
        }
        return "";
    }
    public func getNameFor(type: PFSeparatorType) -> String {
        if let s = c.getNameFor(type){
            return s
        }
        return "";
    }

    
}
