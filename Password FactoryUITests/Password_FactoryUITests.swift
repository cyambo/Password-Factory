//
//  Password_FactoryUITests.swift
//  Password FactoryUITests
//
//  Created by Cristiana Yambo on 10/23/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

import XCTest

class Password_FactoryUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRandom() {
        
        
        let passwordFactoryWindow = XCUIApplication().windows["Password Factory"]
        passwordFactoryWindow/*@START_MENU_TOKEN@*/.tabs["Random"]/*[[".tabGroups.tabs[\"Random\"]",".tabs[\"Random\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.click()
        
        XCUIApplication().sliders.element.adjust(toNormalizedSliderPosition: 0.7)
        let passwordLength = XCUIApplication().windows["Password Factory"]/*@START_MENU_TOKEN@*/.staticTexts["Password Length"]/*[[".tabGroups",".staticTexts[\"30\"]",".staticTexts[\"Password Length\"]",".staticTexts[\"passwordLength\"]"],[[[-1,3],[-1,2],[-1,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1]]],[1]]@END_MENU_TOKEN@*/
        let length = Int(passwordLength.value as! String)!
        let passwordValue = XCUIApplication().windows["Password Factory"]/*@START_MENU_TOKEN@*/.textFields["passwordValue"]/*[[".textFields[\"Password Value\"]",".textFields[\"passwordValue\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let actualLength = (passwordValue.value as! String).count
//        XCTAssertTrue(actualLength == length, "Password length should match")
        
    }
    
}
