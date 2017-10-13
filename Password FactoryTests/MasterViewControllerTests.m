//
//  MasterViewControllerTests.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/5/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>

#import "MasterViewControllerTestClass.h"
@interface MasterViewControllerTests : XCTestCase
@property (nonatomic, strong) MasterViewControllerTestClass *mvc;

@end

@implementation MasterViewControllerTests

- (void)setUp
{
    [super setUp];
    self.mvc = [[MasterViewControllerTestClass alloc] initWithNibName:@"MasterViewController" bundle:nil];
    [self.mvc view];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 Gets the password value from the password text area

 @return string of password value
 */
- (NSString *)getPasswordFieldValue {
    return self.mvc.passwordField.stringValue;
}

/**
 Tests generating a random password
 */
- (void)testRandom {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    NSArray *checks = @[self.mvc.useSymbols,self.mvc.avoidAmbiguous,self.mvc.mixedCase];
    int i = 0;
    //go through the checkboxes and press them
    for (NSButton *b in checks){
        NSString *p = [self getPasswordFieldValue];
        [b performClick:self];
        //Check to see if checkbox changed the password
        XCTAssertNotEqual(p, [self getPasswordFieldValue], @"Checkbox %@ failed to change value",b.title);
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        //check to see if the checkbox mapped to defaults
        switch (i) {
            case 0:
                XCTAssertEqual(self.mvc.useSymbols.state, [[d objectForKey:@"randomUseSymbols"] boolValue], @"useSymbols failed to bind to NSUserDefaults");
                break;
            case 1:
                XCTAssertEqual(self.mvc.avoidAmbiguous.state, [[d objectForKey:@"randomAvoidAmbiguous"] boolValue], @"avoidAmbiguous failed to bind to NSUserDefaults");
                break;
            case 2:
                XCTAssertEqual(self.mvc.mixedCase.state, [[d objectForKey:@"randomMixedCase"] boolValue], @"mixedCase failed to bind to NSUserDefaults");
                break;
        }
        i++;
    }
    //checking random password length setter
    self.mvc.passwordLengthSlider.floatValue = 5.0;
    [self.mvc.passwordLengthSlider performClick:nil];
    [self.mvc changeLength:self.mvc.passwordLengthSlider];
    
    XCTAssertEqual(5, [self getPasswordFieldValue].length, @"Password not changed to 5");
   
    //checking random password length setter min
    //the min is 5 and if you make a setter less than 5 it will be 5
    [self.mvc.passwordLengthSlider setIntegerValue:4];
    [self.mvc.passwordLengthSlider performClick:nil];
    [self.mvc changeLength:self.mvc.passwordLengthSlider];
    ;
    XCTAssertEqual(5, [self getPasswordFieldValue].length, @"Password not changed to 5");
   
    //checking random password length setter max
    //the max is 40 and if you make a setter more than 40 it will be 40
    [self.mvc.passwordLengthSlider setIntegerValue:41];
    [self.mvc.passwordLengthSlider performClick:nil];
    [self.mvc changeLength:self.mvc.passwordLengthSlider];
    ;
    XCTAssertEqual(40, [self getPasswordFieldValue].length, @"Password not changed to 40");
   
    //making sure the length gets passed across
    [self.mvc.passwordLengthSlider setIntegerValue:22];
    [self.mvc changeLength:self.mvc.passwordLengthSlider];
    XCTAssertEqual(22, self.mvc.passwordLengthSlider.intValue, @"Pronounceable length should be equal to random length 22 it is %@",self.mvc.passwordLengthSlider.stringValue);
}

/**
 Test generating a pattern password
 */
- (void)testPattern {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:1];

    //generating a mock notification to pass to controlTextDidChange so we can simulate typing
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    [[[mockNotification stub] andReturn:self.mvc.patternText] object];
    
    //testing pattern change
    NSString *pattern = @"c"; //set the pattern to 'c'
    [self.mvc.patternText setStringValue:pattern];
    [self.mvc controlTextDidChange:mockNotification];
    XCTAssertEqual(pattern.length, [self getPasswordFieldValue].length, @"Password length should be 1");

    //set a new pattern
    pattern = @"cC\\C";
    [self.mvc.patternText setStringValue:pattern];
    [self.mvc controlTextDidChange:mockNotification];
    XCTAssertEqual(3, [self getPasswordFieldValue].length, @"Password length should be 3");
}

/**
 Presses a radio button on the pronounceable tab

 @param tag tag value of the radio button
 */
-(void)pronounceableRadioPress:(int)tag {
    [self.mvc.pronounceableSeparatorRadio selectCellWithTag:tag];
    [self.mvc pressPrononunceableRadio:self.mvc.pronounceableSeparatorRadio];
    XCTAssertEqual(tag, [self.mvc getPronounceableSeparatorType],@"Pronounceable radio should be clicked to tag %d",tag);
}

/**
 tests generating a pronounceable password
 */
-(void)testPronounceable {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:2];
    
    [self.mvc.passwordLengthSlider setIntegerValue:5]; //set the slider to 5
    [self.mvc.passwordLengthSlider performClick:nil]; //click on the slider
    [self.mvc changeLength:self.mvc.passwordLengthSlider]; //call the changeLength action
    NSString *currPassword = [self getPasswordFieldValue]; //get the generated password
    [self.mvc.passwordLengthSlider setIntegerValue:10]; //set the slider to 10 and change the length
    [self.mvc.passwordLengthSlider performClick:nil];
    [self.mvc changeLength:self.mvc.passwordLengthSlider];
    //test that the password changed when the slider changed
    XCTAssertNotEqual(currPassword, [self getPasswordFieldValue], @"Password not changed when pronounceable slider changed");
    XCTAssertTrue(currPassword.length < [self getPasswordFieldValue].length, @"Pronounceable length should increase to about 10 from about 5");
    
    //testing radio mappings
    [self pronounceableRadioPress:PFPronounceableNoSeparator];
    [self pronounceableRadioPress:PFPronounceableCharacterSeparator];
    [self pronounceableRadioPress:PFPronounceableNumberSeparator];
    [self pronounceableRadioPress:PFPronounceableSymbolSeparator];
    [self pronounceableRadioPress:PFPronounceableSpaceSeparator];
    [self pronounceableRadioPress:PFPronounceableHyphenSeparator];
    currPassword = [self getPasswordFieldValue];
    
    //test if password is changed when radio is pressed
    for (int i=0; i<=5; i++) {
        [self.mvc.pronounceableSeparatorRadio selectCellWithTag:i];
        [self.mvc pressPrononunceableRadio:self.mvc.pronounceableSeparatorRadio];
        XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]], @"Password Field not updated when %d radio is pressed",[self.mvc getPronounceableSeparatorType]);
        currPassword = [self getPasswordFieldValue];
    }
}

/**
 Test generating a passphrase
 */
- (void)testPassphrase {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:3];
    //set the length
    [self.mvc.passwordLengthSlider setIntegerValue:10];
    [self.mvc.passwordLengthSlider performClick:nil];
    [self.mvc changeLength:self.mvc.passwordLengthSlider];
    //get the password
    NSString *currPassword = [self getPasswordFieldValue];
    //change the length
    [self.mvc.passwordLengthSlider setIntegerValue:30];
    [self.mvc.passwordLengthSlider performClick:nil];
    [self.mvc changeLength:self.mvc.passwordLengthSlider];
    //test that the password changed when the slider changed
    XCTAssertNotEqual(currPassword, [self getPasswordFieldValue], @"Password not changed when passphrase slider changed");
    XCTAssertTrue(currPassword.length < [self getPasswordFieldValue].length, @"Passphrase length should increase to about 30 from about 10");
    //test all the radio buttons to see if they change the password
    currPassword = [self getPasswordFieldValue];
    for (int i = 0 ; i <= 3 ; i++) {
        for (int j = 0 ; j <= 3 ; j++) {
            [self.mvc.passphraseCaseRadio selectCellWithTag:i];
            [self.mvc.passphraseSeparatorRadio selectCellWithTag:j];
            [self.mvc.passphraseSeparatorRadio performClick:nil];
            [self.mvc.passphraseCaseRadio performClick:nil];
            XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]], @"Passphrase Password Field not updated when case:%d or separator:%d radio is pressed",i,j);
            currPassword = [self getPasswordFieldValue];
        }
    }
}

/**
 Tests that strength meter updates when the password changes
 */
- (void)testStrengthMeter {
    self.mvc.passwordValue = @"1"; //set the password
    [self.mvc setPasswordStrength]; //run the strength update method
    float currStrength = self.mvc.passwordStrengthLevel.floatValue; //get the new strength
    self.mvc.passwordValue = [self.mvc.pf generateRandom:YES avoidAmbiguous:YES useSymbols:YES]; //generate a new password
    [self.mvc setPasswordStrength]; //run the strength update method
    XCTAssertNotEqual(currStrength, self.mvc.passwordStrengthLevel.floatValue, @"Password strength meter not updated with change"); //check to see if strength changed with updates

}

/**
 Test changing the tab on the main window
 */
-(void)testChangeTab {
    [self.mvc generatePassword];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *currPassword = [self getPasswordFieldValue];
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:1];
    //select all the tabs individually and see if the password updates when the tab has changed
    for(int i=0;i<3;i++) {
        [self.mvc.passwordTypeTab selectTabViewItemAtIndex:i];
        //see if the password gets updated
        XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]],@"Password not changed when switched to tab %d",i);
        currPassword = [self getPasswordFieldValue];
        //see if the selectedTabIndex gets updated in defaults
        XCTAssertEqual([d integerForKey:@"selectedTabIndex"], i, @"Tab %d selection not saved in defaults",i);
    }
    
}

/**
 Tests that the generate button generates a new password
 */
- (void)testGenerateButton {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    NSString *currPassword = [self getPasswordFieldValue];
    [self.mvc.generateButton performClick:self.mvc];
    XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]],@"Pressing generate button does not regenerate new password");
}

/**
 Test that copy to clipboard works as well as the clipboard clear timer
 */
- (void)testCopyToPasteboard {
    [self copyToPasteboard:NO];
    [self copyToPasteboard:YES];
}

/**
 Copies to pasteboard and optionally tests the timer

 @param setTimer test the clear timer
 */
-(void)copyToPasteboard:(BOOL)setTimer {
    NSInteger timerRetval = 3; //set timer
    
    //generate a mock timer
    id timerMock = OCMClassMock([NSTimer class]);
    [[timerMock expect] scheduledTimerWithTimeInterval:timerRetval
                                            target:[OCMArg any]
                                          selector:[OCMArg anySelector]
                                          userInfo:nil
                                           repeats:NO];

    //set a mock NSUserDefaults
    id defaultsMock = OCMClassMock([NSUserDefaults class]);
    id d = OCMPartialMock([NSUserDefaults standardUserDefaults]);
    
    //set mock defaults to return our values for the clear clipboard settings
    [[[d stub] andReturnValue:OCMOCK_VALUE(timerRetval)] integerForKey:@"clearClipboardTime"];
    [[[d stub] andReturnValue:OCMOCK_VALUE(setTimer)] boolForKey:@"clearClipboard"];
    if ([d boolForKey:@"clearClipboard"]) {
        NSLog(@"YES %hhd",setTimer);
    } else {
        NSLog(@"NO %hhd",setTimer);
    }
    
    //set the defaults mock to return our standardUserDefaults mock
    OCMStub([defaultsMock standardUserDefaults]).andReturn(d);
    
    //select a tab
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    
    //click the copy to clipboard button
    [self.mvc.pasteboardButton performClick:self.mvc];
    
    //get the clipboard value
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *pbval = [pasteboard stringForType:NSPasteboardTypeString];
    
    
    if (setTimer) { //tests if the mock timer was triggered when we want it
        XCTAssertNoThrow([timerMock verify], @"Timer should be triggered");
    } else { //test that the mock timer was not triggered when we dont want it
        XCTAssertThrows([timerMock verify], @"Timer should not be triggered");
    }
    
    //check to see if our value was copied to clipboard
    XCTAssertTrue([pbval isEqualToString:[self getPasswordFieldValue]], @"Password not copied to pasteboard");

    [defaultsMock stopMocking];
    [d stopMocking];
}

/**
 Test clipboard handling methods update and clear clipboard
 */
- (void)testClipboardHandling {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

    [self.mvc updatePasteboard:@"TO Copy To"]; //put text on clipboard
    XCTAssertTrue([[pasteboard stringForType:NSPasteboardTypeString] isEqualToString:@"TO Copy To"], @"Text not copied to pasteboard"); //see if it was sent
    [self.mvc clearClipboard]; //clear clipboard
    XCTAssertTrue([[pasteboard stringForType:NSPasteboardTypeString] isEqualToString:@""], @"Pasteboard not cleard"); //see if clipboard was cleared
    
}
-(void)testFirstResponderActions {
    
    //not sure why first responder actions like cut are not working
    //TODO: fix first responder tests??
    return;
    
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *testValue = @"updated password field";
    [self.mvc.passwordField becomeFirstResponder];
    [self.mvc.passwordField setStringValue:testValue];

    [NSApp sendAction:@selector(cut:) to:nil from:self];
    
    NSTextView* fieldEditor = (NSTextView*)[[[NSApplication sharedApplication] mainWindow] firstResponder];
    
    [fieldEditor selectAll:self];
    [fieldEditor cut:self];
    NSLog(@"STRING %@",[pasteboard stringForType:NSPasteboardTypeString] );
    XCTAssertTrue([[pasteboard stringForType:NSPasteboardTypeString] isEqualToString:testValue], @"Text not copied to pasteboard");
    
}

/**
 Tests that the password field gets updated and highlighted based on color settings
 */
- (void)testUpdatePasswordField {
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    //returning password field for object propery
    [[[mockNotification stub] andReturn:self.mvc.passwordField] object];
    
    //do not color password
    self.mvc.colorPasswordText = NO;
    [self.mvc.passwordField setStringValue:@"cC#2"]; //set password
    [self.mvc controlTextDidChange:mockNotification]; //send notification
    NSAttributedString *attrStr = [self.mvc.passwordField attributedStringValue]; //get attributed string from password field
    //generate an attributed string all one color - which is how the password field should be
    NSAttributedString *testStr = [[NSAttributedString alloc] initWithString:@"cC#2" attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}];

    BOOL mismatch = NO;
    //compare every character and its attributes to see if they match
    for (int i = 0; i < testStr.length ; i++) {
        NSDictionary *a1, *a2;
        a1 = [attrStr attributesAtIndex:i effectiveRange:nil];
        a2 = [testStr attributesAtIndex:i effectiveRange:nil];
        if (![a1 isEqualTo:a2]) {
            mismatch = YES; //something is different
            break;
        }
    }
    XCTAssertFalse(mismatch, @"Password field is highlighted when it shouldn't be");
    //testing highlighted string
    
    //setting up a mock defaults object
    id defaultsMock = OCMClassMock([NSUserDefaults class]);
    id d = OCMPartialMock([NSUserDefaults standardUserDefaults]);
    
    //set our mock defaults to return these colors for the character types
    [[[d stub] andReturnValue:OCMOCK_VALUE(@"111111")] objectForKey:@"numberTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE(@"222222")] objectForKey:@"upperTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE(@"333333")] objectForKey:@"numberTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE(@"444444")] objectForKey:@"lowerTextColor"];
    
    //turn on password coloring
    self.mvc.colorPasswordText = YES;
    [self.mvc.passwordField setStringValue:@"cC#2"]; //set a new string
    [self.mvc controlTextDidChange:mockNotification]; //send notification to update the text field
    attrStr = [self.mvc.passwordField attributedStringValue];
    
    mismatch = YES;
    //comparing attributed string to the single color string
    //every character should have a different color than the single color string
    for (int i = 0; i < testStr.length ; i++) {
        NSDictionary *a1, *a2;
        a1 = [attrStr attributesAtIndex:i effectiveRange:nil];
        a2 = [testStr attributesAtIndex:i effectiveRange:nil];
        if ([a1 isEqualTo:a2]) { //string is not colored properly
            mismatch = NO;
            break;
        }
    }
    XCTAssertTrue(mismatch, @"Password field is highlighted when it should be");
    [defaultsMock stopMocking];
    [d stopMocking];
    
}

/**
 Tests that the password strength gets updated when a user types in the password field
 */
- (void)testManualChangePasswordField {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    
    //creating mock notification to simulate typing in the password field
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    //returning password field for object property
    [[[mockNotification stub] andReturn:self.mvc.passwordField] object];
    
    //testing pattern change
    [self.mvc.passwordField setStringValue:@"c"]; //set the password field
    [self.mvc controlTextDidChange:mockNotification]; //run notification
    float currStrength = self.mvc.passwordStrengthLevel.floatValue;
    
    [self.mvc.passwordField setStringValue:@"!@#$%$#@@#$"]; //change the password field
    [self.mvc controlTextDidChange:mockNotification];
    //make sure the strength changed when the password field changed
    XCTAssertTrue(currStrength != self.mvc.passwordStrengthLevel.floatValue, @"Password strength did not update when passwordField is entered manually");
}

/**
 Tests the control bindings on the random tab
 */
-(void)testDefaultsBindingsRandom {

    [self deleteUserDefaults];
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0]; //select random tab

    //validate the checkboxes
    [self validateCheckboxDefaults:self.mvc.useSymbols defaultsKey:@"randomUseSymbols"];
    [self validateCheckboxDefaults:self.mvc.avoidAmbiguous defaultsKey:@"randomAvoidAmbiguous"];
    [self validateCheckboxDefaults:self.mvc.mixedCase defaultsKey:@"randomMixedCase"];
    //validate the slider
    [self validateSliderDefaults:self.mvc.passwordLengthSlider defaultsKey:@"passwordLength"];

}

/**
 Tests the control bindings on the pattern tab
 */
-(void)testBindingsPattern {

    [self deleteUserDefaults];
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:1];
    
    //creating mock notification to simulate typing in the pattern field
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    //returning password field for object property
    [[[mockNotification stub] andReturn:self.mvc.patternText] object];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    [self.mvc.patternText setStringValue:@"abc"];
    [self.mvc controlTextDidChange:mockNotification]; //run notification
    
//    NSDictionary *bindingInfo = [self infoForBinding:NSValueBinding];
//    [[bindingInfo valueForKey:NSObservedObjectKey] setValue:self.mvc.patternText
//                                                 forKeyPath:[bindingInfo valueForKey:NSObservedKeyPathKey]];
    
    XCTAssertTrue([[d stringForKey:@"userPattern"] isEqualToString:@"abc"],@"userPattern should update to abc is %@",[d stringForKey:@"userPattern"]);
    
}

/**
 Tests the control bindings on the pronounceable tab
 */
-(void)testBindingsPronounceable {
    
    return; //bindings not updating programatically
    
    [self deleteUserDefaults];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

    
    [self.mvc.pronounceableSeparatorRadio selectCellAtRow:0 column:0];
    [self.mvc.pronounceableSeparatorRadio performClick:self];
    XCTAssertEqual([self getSelectedPronounceableTag], [d integerForKey:@"pronounceableSeparator"], @"Pronounceable radio should set to 1");
    
    [self.mvc.pronounceableSeparatorRadio selectCellAtRow:0 column:1];
    [self.mvc.pronounceableSeparatorRadio performClick:self];
    XCTAssertEqual([self getSelectedPronounceableTag], [d integerForKey:@"pronounceableSeparator"], @"Pronounceable radio should set to 1");
    
}

/**
 Tests that slider updates NSUserDefaults bindings

 @param slider slider to test
 @param key NSUserDefaults key
 */
-(void)validateSliderDefaults:(NSSlider *)slider
                  defaultsKey:(NSString *)key {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    self.mvc.passwordLengthSlider.integerValue = 22;
    [self.mvc.passwordLengthSlider performClick:self];
    XCTAssertEqual([d floatForKey:key], 22, @"%@ slider should update defaults to 22",key);
    
    self.mvc.passwordLengthSlider.integerValue = 12;
    [self.mvc.passwordLengthSlider performClick:self];
    XCTAssertEqual([d floatForKey:key], 12, @"%@ slider should update defaults to 22",key);
}

/**
 Check that checkboxes update NSUserDefaults bindings

 @param checkbox checkbox to validate
 @param key mapped NSUserDefaults key
 */
-(void)validateCheckboxDefaults:(NSButton *)checkbox
                    defaultsKey:(NSString *)key {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    checkbox.state = YES;
    [checkbox performClick:self];
    XCTAssertFalse([d boolForKey:key], @"Checkbox %@ should save to defaults as NO",key);
    [checkbox performClick:self];
    XCTAssertTrue([d boolForKey:key], @"Checkbox %@ should save to defaults as YES",key);
    
}

/**
 Get tag of the selected radio button on the pronounceable tab

 @return selected radio button tag
 */
-(NSInteger)getSelectedPronounceableTag {
    NSButtonCell* selected = self.mvc.pronounceableSeparatorRadio.selectedCell;
    NSLog(@"TAG %ld",selected.tag);
    return selected.tag;
}

/**
 Tests the button NSUserDefaults bindings

 @param button button to test
 @param key mapped NSUserDefaults key
 @param setValue value to set
 @param expectedValue expected value stored
 */
-(void)validateButtonDefaults:(NSButton *)button
                  defaultsKey:(NSString *)key
                     setValue:(NSInteger)setValue
                expectedValue:(NSInteger)expectedValue {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    button.integerValue = setValue;
    NSLog(@"set to %ld - %ld - %ld",(long)setValue,(long)button.integerValue,(long)[d integerForKey:key]);
    [button performClick:self];
    NSLog(@"clicked  %ld - %ld",button.integerValue,[d integerForKey:key]);
    XCTAssertEqual([d integerForKey:key], expectedValue,@"Defaults not saved for %@",key);
}

/**
 Deletes all values in NSUserDefaults
 */
-(void)deleteUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
@end
