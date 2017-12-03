//
//  PFConstants.swift
//  Password Factory iOS
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import UIKit

final class PFConstants: NSObject {
    static let instance = PFConstants() //access this for singleton
    let c = PasswordFactoryConstants.get()!
//    let phoneticSounds: [String]
//    let phoneticSoundsTwo: [String]
//    let phoneticSoundsThree: [String]
//    let passwordCharacterTypes: [PFCharacterType:String]
//    let passwordTypes: [PFPasswordType:String]
//    let passwordNameToType: [String:PFPasswordType]
//    let caseTypes: [PFCaseType:String]
//    let separatorTypes: [PFSeparatorType:String]
//    let patternCharacterToType: [String:PFPatternTypeItem]
//    let patternTypeToName: [PFPatternTypeItem:String]
//    let patternTypeToCharacter: [PFPatternTypeItem:String]
//    let passwordTypesIndex: [PFPasswordType]
//    let caseTypesIndex: [PFCaseType]
//    let separatorTypeIndex: [PFSeparatorType]
//    let patternTypeIndex: [PFPatternTypeItem]
    
    //init is private for singleton
    private override init() {
        print("UP")
    }
    
}
