//
//  MasterViewControllerTests.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/5/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "NSColor+NSColorHexadecimalValue.h"
#import "MasterViewController.h"
#import "DefaultsManager.h"
#import "MainWindowController.h"
#import "PasswordFactoryConstants.h"
#import "NSString+ColorWithHexColorString.h"
#import "PatternTextView.h"
@interface MasterViewControllerTests : XCTestCase
@property (nonatomic, strong) MasterViewController *mvc;

@end

@implementation MasterViewControllerTests

- (void)setUp {
    [super setUp];
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    MainWindowController *windowController = [storyBoard instantiateControllerWithIdentifier:@"MainWindowController"];
    self.mvc = (MasterViewController *)windowController.window.contentViewController;
}

- (void)tearDown {
    [super tearDown];
}
/**
 Test that copy to clipboard works as well as the clipboard clear timer
 */
- (void)testCopyToPasteboard {
    [self copyToPasteboard:NO];
    [self copyToPasteboard:YES];
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

/**
 Test generating a pattern password
 */
- (void)testPattern {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    [self.mvc selectPaswordType:PFPatternType];
    PasswordTypesViewController *pvc = self.mvc.currentPasswordTypeViewController;
    //generating a mock notification to pass to controlTextDidChange so we can simulate typing
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    [[[mockNotification stub] andReturn:pvc.patternText] object];
    
    //testing pattern change
    NSString *pattern = @"c"; //set the pattern to 'c'
    [pvc.patternText resetText:pattern];
    [d setObject:pattern forKey:@"userPattern"];
    [pvc controlTextDidChange:mockNotification];
    XCTAssertEqual(pattern.length, [self getPasswordFieldValue].length, @"Password length should be 1");
    
    //set a new pattern
    pattern = @"cC\\C";
    [pvc.patternText resetText:pattern];
    [d setObject:pattern forKey:@"userPattern"];
    [pvc controlTextDidChange:mockNotification];
    
    XCTAssertEqual(3, [self getPasswordFieldValue].length, @"Password length should be 3");
}
/**
 tests generating a pronounceable password
 */
-(void)testPronounceable {
    [self testLengthSeparatorAndCaseType:PFPronounceableType];
}
/**
 tests generating a pronounceable password
 */
-(void)testPassphrase {
    [self testLengthSeparatorAndCaseType:PFPassphraseType];
}

/**
 Tests the display crack time button
 */
-(void)testDisplayCrackTime {
    
    NSUserDefaults * d = [DefaultsManager standardDefaults];
    
    NSButton *b = self.mvc.crackTimeButton;
    NSString *key = @"displayCrackTime";
    
    [self validateButtonBinding:b defaultsKey:key];
    if ([d boolForKey:key] == TRUE) {
        [b performClick:self];
    }
    XCTAssertTrue(b.alphaValue == 0,@"Alpha Value of Crack time button should be 0");
    [b performClick:self];
    XCTAssertTrue(b.alphaValue == 1,@"Alpha Value of Crack time button should be 1");
}
/**
 Tests that the password field gets updated and highlighted based on color settings
 */
- (void)testColorPasswordField {
    PasswordFactory *factory = [PasswordFactory get];
    NSUserDefaults *defaults = [DefaultsManager standardDefaults];
    NSColor *upperTextColor = [NSColor greenColor];
    NSColor *lowerTextColor = [NSColor orangeColor];
    NSColor *numberTextColor = [NSColor purpleColor];
    NSColor *symbolTextColor = [NSColor redColor];
    NSColor *defaultTextColor = [[defaults stringForKey:@"defaultTextColor"] colorWithHexColorString];
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    //returning password field for object propery
    [[[mockNotification stub] andReturn:self.mvc.passwordField] object];
    //generate a string with all the possible characters that can be highlighted, and some characters that should not be highlighted
    
    NSString *testString = [NSString stringWithFormat:@"%@áéíòü",[factory getPasswordCharacterType:PFAllCharacters]];
    //do not color password
    [defaults setBool:NO forKey:@"colorPasswordText"];
    
    [self.mvc.passwordField setStringValue:testString]; //set password
    [self.mvc controlTextDidChange:mockNotification]; //send notification
    NSAttributedString *attrStr = [self.mvc.passwordField attributedStringValue]; //get attributed string from password field
    //generate an attributed string all one color - which is how the password field should be
    NSDictionary *attributes = @{
                                NSForegroundColorAttributeName: defaultTextColor,
                                NSFontAttributeName: [NSFont systemFontOfSize:17]
                                };
    NSAttributedString *testStr = [[NSAttributedString alloc] initWithString:testString attributes:attributes];
    
    BOOL mismatch = NO;
    //compare every character and its attributes to see if they match
    for (int i = 0; i < testStr.length ; i++) {
        NSColor *c1, *c2;
        c1 = [attrStr attributesAtIndex:i effectiveRange:nil][@"NSColor"];
        c2 = [testStr attributesAtIndex:i effectiveRange:nil][@"NSColor"];
        if (![c1 isEqual:c2]) {
            mismatch = YES; //something is different
            break;
        }
    }
    XCTAssertFalse(mismatch, @"Password field is highlighted when it shouldn't be");
    //testing highlighted string to see if it gets highlighted when it shouldn't
    //setting up a mock defaults object
    id defaultsMock = OCMClassMock([NSUserDefaults class]);
    id d = OCMPartialMock([NSUserDefaults standardUserDefaults]);
    
    //set our mock defaults to return these colors for the character types
    [[[d stub] andReturnValue:OCMOCK_VALUE([numberTextColor hexadecimalValueOfAnNSColor])] objectForKey:@"numberTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE([upperTextColor hexadecimalValueOfAnNSColor])] objectForKey:@"upperTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE([lowerTextColor hexadecimalValueOfAnNSColor])] objectForKey:@"lowerTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE([symbolTextColor hexadecimalValueOfAnNSColor])] objectForKey:@"symbolTextColor"];
    
    //turn on password coloring
    [defaults setBool:YES forKey:@"colorPasswordText"];
    [self.mvc.passwordField setStringValue:testString]; //set a new string
    [self.mvc controlTextDidChange:mockNotification]; //send notification to update the text field
    attrStr = [self.mvc.passwordField attributedStringValue];
    
    mismatch = NO;
    NSString *at = @"";
    
    //testing that the password string is properly highlighted for each of the possible character types that are highlighted
    for (int i = 0; i < testStr.length ; i++) {
        NSDictionary *a1, *a2;
        a1 = [attrStr attributesAtIndex:i effectiveRange:nil];
        a2 = [testStr attributesAtIndex:i effectiveRange:nil];
        
        NSColor *atColor = a1[@"NSColor"];
        
        NSDictionary *colorMap = @{
                                   @(PFUpperCaseLetters): upperTextColor,
                                   @(PFLowerCaseLetters): lowerTextColor,
                                   @(PFNumbers): numberTextColor,
                                   @(PFSymbols): symbolTextColor
                                   };
        
        at = [NSString stringWithFormat:@"%c", [testString characterAtIndex:i]];
        BOOL foundType = NO;
        for(NSNumber *key in [colorMap allKeys]) {
            PFCharacterType type = (PFCharacterType)key.intValue;
            if ([factory isCharacterType:type character:at]) {
                foundType = YES;
                if (![atColor isEqual: colorMap[key]]) {
                    mismatch = YES;
                    break;
                }
            }
        }
        if (!foundType) {
            if (![atColor isEqual:defaultTextColor]) {
                mismatch = YES;
                break;
            }
        }
    }
    XCTAssertTrue(mismatch, @"Password field at character %@ is not highlighted properly",at);
    [defaultsMock stopMocking];
    [d stopMocking];
    
}
/**
 Tests that strength meter updates when the password changes
 */
- (void)testStrengthMeter {
    [self.mvc.password setPasswordValue:@"1"]; //set the password
    [self.mvc setPasswordStrength]; //run the strength update method
    float currStrength = self.mvc.passwordStrengthLevel.floatValue; //get the new strength
    NSDictionary *settings = @{
                               @"caseType": @(PFMixedCase),
                               @"avoidAmbiguous":@(YES),
                               @"useSymbols":@(YES)
                               };
    [self.mvc.password generatePassword:PFRandomType withSettings:settings];

    XCTAssertNotEqual(currStrength, self.mvc.passwordStrengthLevel.floatValue, @"Password strength meter not updated with change"); //check to see if strength changed with updates
    
}
/**
 Tests that the generate button generates a new password
 */
- (void)testGenerateButton {
    [self.mvc selectPaswordType:PFRandomType];
    NSString *currPassword = [self getPasswordFieldValue];
    [self.mvc.generateButton performClick:self.mvc];
    XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]],@"Pressing generate button does not regenerate new password");
}

/**
 Tests that the password strength gets updated when a user types in the password field
 */
- (void)testManualChangePasswordField {
    [self.mvc selectPaswordType:PFRandomType];
    
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
 Test changing the tab on the main window
 */
-(void)testChangeType {
    [self.mvc selectPaswordType:PFPatternType];
    [self.mvc generatePassword];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *currPassword = [self getPasswordFieldValue];
    
    //select all the tabs individually and see if the password updates when the tab has changed
    for(int i=0;i<3;i++) {
        PFPasswordType type = (i + PFRandomType);
        [self.mvc selectPaswordType:type];
        //see if the password gets updated
        XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]],@"Password not changed when switched to tab %d",i);
        currPassword = [self getPasswordFieldValue];
        //see if the selectedTabIndex gets updated in defaults
        XCTAssertEqual([d integerForKey:@"selectedPasswordType"], type, @"Tab %d selection not saved in defaults",i);
    }
}
/**
 Tests the control bindings on the random tab
 */
-(void)testDefaultsBindingsRandom {
    
    [self deleteUserDefaults];
    [self.mvc selectPaswordType:PFRandomType]; //select random tab
    
    //validate the checkboxes
    PasswordTypesViewController *pvc = self.mvc.currentPasswordTypeViewController;
    [self validateCheckboxDefaults:pvc.useSymbols defaultsKey:@"randomUseSymbols"];
    [self validateCheckboxDefaults:pvc.avoidAmbiguous defaultsKey:@"randomAvoidAmbiguous"];

    //validate the slider
    [self validateSliderDefaults:pvc.passwordLengthSlider defaultsKey:@"passwordLength"];
}

#pragma mark Utilities
-(void)testLengthSeparatorAndCaseType:(PFPasswordType)type {
    [self.mvc selectPaswordType:type];
    //test length changing
    [self lengthTest:type];
    //case type test
    [self caseTypeTest:type];
    //test separator type
    [self separatorTypeTest:type];
    //test slider
    NSSlider *slider = self.mvc.currentPasswordTypeViewController.passwordLengthSlider;
    [self validateSliderDefaults:slider defaultsKey:@"passwordLength"];
}

-(void)lengthTest:(PFPasswordType)passwordType {
    [self.mvc selectPaswordType:passwordType];
    PasswordTypesViewController *pvc = self.mvc.currentPasswordTypeViewController;
    PasswordFactoryConstants *c = [PasswordFactoryConstants get];
    [pvc.passwordLengthSlider setIntegerValue:5]; //set the slider to 5
    [pvc.passwordLengthSlider performClick:nil]; //click on the slider
    [pvc changeLength:pvc.passwordLengthSlider]; //call the changeLength action
    NSString *currPassword = [self getPasswordFieldValue]; //get the generated password
    [pvc.passwordLengthSlider setIntegerValue:50]; //set the slider to 10 and change the length
    [pvc.passwordLengthSlider performClick:nil];
    [pvc changeLength:pvc.passwordLengthSlider];
    //test that the password changed when the slider changed
    NSString *name = [c getNameForPasswordType:passwordType];
    XCTAssertNotEqual(currPassword, [self getPasswordFieldValue], @"Password not changed when %@ length slider changed",name);
    XCTAssertTrue(currPassword.length < [self getPasswordFieldValue].length, @"%@ length should increase to about 50 from about 5",name);
}
/**
 Tests all the case types for a password type

 @param type Password type to test
 */
-(void)caseTypeTest:(PFPasswordType)type {
    [self.mvc selectPaswordType:type];
    PasswordFactoryConstants *c = [PasswordFactoryConstants get];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    PasswordTypesViewController *pvc = self.mvc.currentPasswordTypeViewController;
    for(int i = 0; i < pvc.caseTypeMenu.numberOfItems; i++) {
        PFCaseType caseType = [c getCaseTypeByIndex:i];
        NSString *passwordTypeName = [c getNameForPasswordType:type];
        NSString *caseTypeName = [c getNameForCaseType:caseType];
        [pvc.caseTypeMenu selectItemAtIndex:i];
        NSString *defaultsKey = [NSString stringWithFormat:@"%@CaseTypeIndex",[passwordTypeName lowercaseString]];
        [d setInteger:i forKey:defaultsKey];
        //set to no separator
        defaultsKey = [NSString stringWithFormat:@"%@SeparatorTypeIndex",[passwordTypeName lowercaseString]];
        [d setInteger:0 forKey:defaultsKey];
        [pvc selectCaseType:pvc.caseTypeMenu];

        NSString *regexString;
        switch(caseType) {
            case PFLowerCase:
                regexString = @"^[a-z]+$";
                break;
            case PFUpperCase:
                regexString = @"^[A-Z]+$";
                break;
            case PFMixedCase:
                regexString = @"^[A-Za-z]+$";
                break;
            case PFTitleCase:
                regexString = @"^([A-Z][a-z]+)+[A-Z]?$";
                break;
        }
        XCTAssertTrue([self regularExpressionTest:regexString toTest:[self getPasswordFieldValue]],@"%@ does not match %@ -- %@",caseTypeName,regexString,[self getPasswordFieldValue]);
    }
}

/**
 Tests all the separator types for a Password Type

 @param type Password type to test
 */
-(void)separatorTypeTest:(PFPasswordType)type {
    [self.mvc selectPaswordType:type];
    PasswordFactoryConstants *c = [PasswordFactoryConstants get];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    PasswordTypesViewController *pvc = self.mvc.currentPasswordTypeViewController;
    for(int i = 0; i < pvc.separatorTypeMenu.numberOfItems; i++) {
        PFSeparatorType separatorType = [c getSeparatorTypeByIndex:i];
        NSString *passwordTypeName = [c getNameForPasswordType:type];
        NSString *separatorTypeName = [c getNameForSeparatorType:separatorType];
        [pvc.separatorTypeMenu selectItemAtIndex:i];
        NSString *defaultsKey = [NSString stringWithFormat:@"%@SeparatorTypeIndex",[passwordTypeName lowercaseString]];
        [d setInteger:i forKey:defaultsKey];
        //set to all caps
        defaultsKey = [NSString stringWithFormat:@"%@CaseTypeIndex",[passwordTypeName lowercaseString]];
        [d setInteger:1 forKey:defaultsKey];
        [pvc selectSeparatorType:pvc.separatorTypeMenu];
        
        NSString *regexString;
        switch(separatorType) {
            case PFNoSeparator:
                regexString = @"^[A-Z]+$";
                break;
            case PFHyphenSeparator:
                regexString = @"^([A-Z]+-)+[A-Z]*$";
                break;
            case PFSpaceSeparator:
                regexString = @"^([A-Z]+ )+[A-Z]*$";
                break;
            case PFUnderscoreSeparator:
                regexString = @"^([A-Z]+_)+[A-Z]*$";
                break;
            case PFNumberSeparator:
                regexString = @"^([A-Z]+[0-9])+[A-Z]*$";
                break;
            case PFSymbolSeparator:
                regexString = @"^([A-Z]+[^A-Za-z])+[A-Z]*$";
                break;
            case PFCharacterSeparator:
                regexString = @"^([A-Z]+[A-Za-z])+[A-Z]*$";
                break;
            case PFEmojiSeparator:
                regexString = @"^([A-Z]+[^A-Za-z]{1,3})+[A-Z]*$";
                break;
            case PFRandomSeparator:
                regexString = @"^([A-Z]+.)+[A-Z]*$";
                break;

        }
        XCTAssertTrue([self regularExpressionTest:regexString toTest:[self getPasswordFieldValue]],@"%@ does not match %@ -- %@",separatorTypeName,regexString,[self getPasswordFieldValue]);
    }
}
-(BOOL)regularExpressionTest:(NSString *)regexString toTest:(NSString *)toTest {
    NSError *error;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:regexString options:0 error:&error];
    NSString *r = [regex stringByReplacingMatchesInString:toTest options:0 range:NSMakeRange(0, toTest.length) withTemplate:@""];
    return r.length == 0;
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
    [self.mvc selectPaswordType:PFRandomType];
    
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
 Tests that slider updates NSUserDefaults bindings

 @param slider slider to test
 @param key NSUserDefaults key
 */
-(void)validateSliderDefaults:(NSSlider *)slider
                  defaultsKey:(NSString *)key {
    [self.mvc selectPaswordType:PFRandomType];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    PasswordTypesViewController *pvc = self.mvc.currentPasswordTypeViewController;
    pvc.passwordLengthSlider.integerValue = 22;
    [pvc.passwordLengthSlider performClick:self];
    XCTAssertEqual([d floatForKey:key], 22, @"%@ slider should update defaults to 22",key);
    
    pvc.passwordLengthSlider.integerValue = 12;
    [pvc.passwordLengthSlider performClick:self];
    XCTAssertEqual([d floatForKey:key], 12, @"%@ slider should update defaults to 22",key);
}

/**
 Check that checkboxes update NSUserDefaults bindings

 @param checkbox checkbox to validate
 @param key mapped NSUserDefaults key
 */
-(void)validateCheckboxDefaults:(NSButton *)checkbox
                    defaultsKey:(NSString *)key {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    checkbox.state = YES;
    [checkbox performClick:self];
    XCTAssertFalse([d boolForKey:key], @"Checkbox %@ should save to defaults as NO",key);
    [checkbox performClick:self];
    XCTAssertTrue([d boolForKey:key], @"Checkbox %@ should save to defaults as YES",key);
    
}

/**
 Validates that clicking a button will toggle the defaults

 @param button button to test
 @param defaultsKey NSUserDefaults key
 */
-(void)validateButtonBinding:(NSButton *)button defaultsKey:(NSString *)defaultsKey {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [button performClick:self];
    BOOL initialDefault = [d boolForKey:defaultsKey];
    [button performClick:self];
    XCTAssertTrue(initialDefault != [d boolForKey:defaultsKey],@"Binding for %@ did not update on click",defaultsKey);
}
/**
 Deletes all values in NSUserDefaults
 */
-(void)deleteUserDefaults {
    [DefaultsManager restoreUserDefaults];
}
/**
 Gets the password value from the password text area
 
 @return string of password value
 */
- (NSString *)getPasswordFieldValue {
    return self.mvc.passwordField.stringValue;
}
@end
