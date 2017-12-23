//
//  Password_Factory_iOSTests.swift
//  Password Factory iOSTests
//
//  Created by Cristiana Yambo on 10/11/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import XCTest
@testable import Password_Factory_iOS

class Password_Factory_iOSTests: XCTestCase {
    let longPassword = "W🇰🇭&c🔊8'⏲C4ZuTcC7z]F📊Q|e🤵AK'Az🇸🇲%📧6)H*[🎟@🇰🇭#CN|GEc}!pL🇲🇩yD!_.🦏aLeGxT☘️N{:D7V🇰🇭Ut📊xv🤵🎟>QA.🦏eK{?6R9🇲🇩[2]wDdW🇰🇭&c🔊8'⏲C4ZuTcC7z]F📊Q|e🤵AK'Az🇸🇲%📧6)H*[🎟@🇰🇭#CN|GEc}!pL🇲🇩yD!_.🦏aLeGxT☘️N{:D7V🇰🇭Ut📊xv🤵🎟>QA.🦏eK{?6R9🇲🇩[2]wDd"
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testHighlightPasswordPerformance() {
        self.measure {
            for _ in 0 ..< 10 {
              _ = Utilities.highlightPasswordString(password: longPassword, font: PFConstants.labelFont)
            }
        }
    }
    func testGetPasswordTextColorPerformance() {
        var charArray = [String]()
        for char in longPassword {
            charArray.append("\(char)")
        }
        self.measure {
            for _ in 0 ..< 10 {
                for c in charArray {
                    _ = ColorUtilities.getPasswordTextColor(c)
                }
            }

        }
    }
    func testUpdatePasswordFieldPerformance() {
        let h = Utilities.highlightPassword(password: longPassword, font: PFConstants.labelFont)
        if let vc = UIApplication.shared.delegate?.window??.rootViewController as? TypeSelectionViewController {
            self.measure {
                vc.passwordDisplay.attributedText = h
            }
            
        }
    }
    func testRandomPasswordPerformance() {
        let f = PasswordFactory.get()
        f?.useEmoji = true
        f?.useSymbols = true
        f?.useNumbers = true
        f?.length = 100
        self.measure {
            for _ in 0 ..< 1000 {
                _ = f?.generateRandom()
            }
        }
    }
    
}
