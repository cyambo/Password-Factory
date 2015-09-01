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
- (NSString *)getPasswordFieldValue {
    return self.mvc.passwordField.stringValue;
}
- (void)testRandom {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    NSArray *checks = @[self.mvc.useSymbols,self.mvc.avoidAmbiguous,self.mvc.mixedCase];
    int i = 0;
    for (NSButton *b in checks){
        NSString *p = [self getPasswordFieldValue];
        [b performClick:self];
        XCTAssertNotEqual(p, [self getPasswordFieldValue], @"Checkbox %@ failed to change value",b.title);
        switch (i) {
            case 0:
                XCTAssertEqual(self.mvc.useSymbols.state, self.mvc.pg.useSymbols, @"useSymbols failed to check");
                break;
            case 1:
                XCTAssertEqual(self.mvc.avoidAmbiguous.state, self.mvc.pg.avoidAmbiguous, @"avoidAmbiguous failed to check");
                break;
            case 2:
                XCTAssertEqual(self.mvc.mixedCase.state, self.mvc.pg.mixedCase, @"mixedCase failed to check");
                break;
                

        }
        i++;
    }
    //checking random password length setter
    [self.mvc.passwordLengthSliderRandom setIntegerValue:5];
    [self.mvc changeLength:self.mvc.passwordLengthSliderRandom];
    
    XCTAssertEqual(5, [self getPasswordFieldValue].length, @"Password not changed to 5");
    XCTAssertEqual(5, self.mvc.passwordLengthLabelPronounceable.intValue, @"Random password length label not changed to 5 it is %@",self.mvc.passwordLengthLabelPronounceable.stringValue);
    
    //checking random password length setter min
    //the min is 5 and if you make a setter less than 5 it will be 5
    [self.mvc.passwordLengthSliderRandom setIntegerValue:4];
    [self.mvc changeLength:self.mvc.passwordLengthSliderRandom];
    ;
    XCTAssertEqual(5, [self getPasswordFieldValue].length, @"Password not changed to 5");
    XCTAssertEqual(5, self.mvc.passwordLengthLabelPronounceable.intValue, @"Random Password length label should be 5 it is %@",self.mvc.passwordLengthLabelPronounceable.stringValue);
    
    //checking random password length setter max
    //the max is 40 and if you make a setter more than 40 it will be 40
    [self.mvc.passwordLengthSliderRandom setIntegerValue:41];
    [self.mvc changeLength:self.mvc.passwordLengthSliderRandom];
    ;
    XCTAssertEqual(40, [self getPasswordFieldValue].length, @"Password not changed to 40");
    XCTAssertEqual(40, self.mvc.passwordLengthLabelPronounceable.intValue, @"Random Password length label should be 40 it is %@",self.mvc.passwordLengthLabelPronounceable.stringValue);
    
    //making sure the length gets passed across
    [self.mvc.passwordLengthSliderRandom setIntegerValue:22];
    [self.mvc changeLength:self.mvc.passwordLengthSliderRandom];
    XCTAssertEqual(22, self.mvc.passwordLengthSliderPrononunceable.intValue, @"Pronounceable length should be equal to random length 22 it is %@",self.mvc.passwordLengthSliderPrononunceable.stringValue);
    XCTAssertEqual(22, self.mvc.passwordLengthLabelPronounceable.intValue, @"Pronounceable length label should be the same as random 22 it is %@",self.mvc.passwordLengthLabelPronounceable);
}
- (void)testPattern {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:1];

    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    [[[mockNotification stub] andReturn:self.mvc.patternText] object];
    
    //testing pattern change
    NSString *pattern = @"c";
    [self.mvc.patternText setStringValue:pattern];

    
    [self.mvc controlTextDidChange:mockNotification];
    XCTAssertEqual(pattern.length, [self getPasswordFieldValue].length, @"Password length should be 1");

    
    pattern = @"cC\\C";
    [self.mvc.patternText setStringValue:pattern];

    [self.mvc controlTextDidChange:mockNotification];
    XCTAssertEqual(3, [self getPasswordFieldValue].length, @"Password length should be 3");


}
-(BOOL)pronounceableRadioPress:(NSString *)toCompare tag:(int)tag {
    
    //FIXME: BROKEN TEST IN MODEL REFACTOR
    return NO;
//    [self.mvc.pronounceableSeparatorRadio selectCellWithTag:tag];
//    [self.mvc pressPrononunceableRadio:self.mvc.pronounceableSeparatorRadio];
//    XCTAssertTrue([[self.mvc getPronounceableSeparatorCode]
//                   isEqualToString:toCompare],
//                  @"Pronouneable radio should be %@ is %@",toCompare,[self.mvc getPronounceableRadioSelected]);
}
-(void)testPronounceable {
    
    
    //FIXME: BROKEN TEST IN MODEL REFACTOR
    
//    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:2];
//    
//    [self.mvc.passwordLengthSliderPrononunceable setIntegerValue:5];
//    [self.mvc changeLength:self.mvc.passwordLengthSliderPrononunceable];
//    NSString *currPassword = [self getPasswordFieldValue];
//    [self.mvc.passwordLengthSliderPrononunceable setIntegerValue:10];
//    [self.mvc changeLength:self.mvc.passwordLengthSliderPrononunceable];
//    XCTAssertNotEqual(currPassword, [self getPasswordFieldValue], @"Password not changed when pronounceable slider changed");
//    XCTAssertTrue(currPassword.length < [self getPasswordFieldValue].length, @"Pronounceable length 5 not less than length 10");
//    
//    //testing radio mappings
//    [self pronounceableRadioPress:@"None" tag:1];
//    [self pronounceableRadioPress:@"Characters" tag:2];
//    [self pronounceableRadioPress:@"Numbers" tag:3];
//    [self pronounceableRadioPress:@"Symbols" tag:4];
//    [self pronounceableRadioPress:@"Spaces" tag:5];
//    [self pronounceableRadioPress:@"Hyphen" tag:0];
//    currPassword = [self getPasswordFieldValue];
//    //test if password is changed when radio is pressed
//    for (int i=0; i<=5; i++) {
//        [self.mvc.pronounceableSeparatorRadio selectCellWithTag:i];
//        [self.mvc pressPrononunceableRadio:self.mvc.pronounceableSeparatorRadio];
//        XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]], @"Password Field not updated when %@ radio is pressed",[self.mvc getPronounceableRadioSelected]);
//        currPassword = [self getPasswordFieldValue];
//    }
}
- (void)testStrengthMeter {
    self.mvc.passwordValue = @"1";
    [self.mvc setPasswordStrength];
    float currStrength = self.mvc.passwordStrengthLevel.floatValue;
    self.mvc.passwordValue = @"!@#$%^&";
    [self.mvc setPasswordStrength];
    XCTAssertNotEqual(currStrength, self.mvc.passwordStrengthLevel.floatValue, @"Password strength meter not updated with change");
}

-(void)testChangeTab {
    [self.mvc generatePassword];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *currPassword = [self getPasswordFieldValue];
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:1];
    for(int i=0;i<3;i++) {
        [self.mvc.passwordTypeTab selectTabViewItemAtIndex:i];
        XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]],@"Password not changed when switched to tab %d",i);
        currPassword = [self getPasswordFieldValue];
        XCTAssertEqual([d integerForKey:@"selectedTabIndex"], i, @"Tab %d selection not saved in defaults",i);
    }
    
}
- (void)testGenerateButton {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    NSString *currPassword = [self getPasswordFieldValue];
    [self.mvc.generateButton performClick:self.mvc];
    XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]],@"Pressing generate button does not regenerate new password");
}
- (void)testCopyToPasteboard {
    [self copyToPasteboard:NO];
    [self copyToPasteboard:YES];
}
-(void)copyToPasteboard:(BOOL)setTimer {

    NSInteger timerRetval = 3;
    
    id timerMock = OCMClassMock([NSTimer class]);
    [[timerMock expect] scheduledTimerWithTimeInterval:timerRetval
                                            target:[OCMArg any]
                                          selector:[OCMArg anySelector]
                                          userInfo:nil
                                           repeats:NO];

    id defaultsMock = OCMClassMock([NSUserDefaults class]);
    
    id d = OCMPartialMock([NSUserDefaults standardUserDefaults]);
    
    [[[d stub] andReturnValue:OCMOCK_VALUE(timerRetval)] integerForKey:@"clearClipboardTime"];
    
    [[[d stub] andReturnValue:OCMOCK_VALUE(setTimer)] boolForKey:@"clearClipboard"];
    if ([d boolForKey:@"clearClipboard"]) {
        NSLog(@"YES %hhd",setTimer);
    } else {
        NSLog(@"NO %hhd",setTimer);
    }

    OCMStub([defaultsMock standardUserDefaults]).andReturn(d);
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    
    [self.mvc.pasteboardButton performClick:self.mvc];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *pbval = [pasteboard stringForType:NSPasteboardTypeString];
    
    if (setTimer) {
        XCTAssertNoThrow([timerMock verify], @"Timer should be triggered");
    } else {
        XCTAssertThrows([timerMock verify], @"Timer should not be triggered");
    }
    
    XCTAssertTrue([pbval isEqualToString:[self getPasswordFieldValue]], @"Password not copied to pasteboard");

    [defaultsMock stopMocking];
    [d stopMocking];
}
- (void)testClipboardHandling {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

    [self.mvc updatePasteboard:@"TO Copy To"];
    XCTAssertTrue([[pasteboard stringForType:NSPasteboardTypeString] isEqualToString:@"TO Copy To"], @"Text not copied to pasteboard");
    [self.mvc clearClipboard];
    XCTAssertTrue([[pasteboard stringForType:NSPasteboardTypeString] isEqualToString:@""], @"Pasteboard not cleard");
    
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
//making sure the password field gets updated and is highlghted based on settings
- (void)testUpdatePasswordField {
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    //returning password field for object propery
    [[[mockNotification stub] andReturn:self.mvc.passwordField] object];
    


    self.mvc.colorPasswordText = NO;
    [self.mvc.passwordField setStringValue:@"cC#2"];
    [self.mvc controlTextDidChange:mockNotification];
    NSAttributedString *attrStr = [self.mvc.passwordField attributedStringValue];

    NSAttributedString *testStr = [[NSAttributedString alloc] initWithString:@"cC#2" attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}];

    BOOL mismatch = NO;
    for (int i = 0; i < testStr.length ; i++) {
        NSDictionary *a1, *a2;
        a1 = [attrStr attributesAtIndex:i effectiveRange:nil];
        a2 = [testStr attributesAtIndex:i effectiveRange:nil];
        if (![a1 isEqualTo:a2]) {
            mismatch = YES;
            break;
        }
    }
    XCTAssertFalse(mismatch, @"Password field is highlighted when it shouldn't be");
    //testing highlighted string

    id defaultsMock = OCMClassMock([NSUserDefaults class]);
    
    id d = OCMPartialMock([NSUserDefaults standardUserDefaults]);
    
    [[[d stub] andReturnValue:OCMOCK_VALUE(@"111111")] objectForKey:@"numberTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE(@"222222")] objectForKey:@"upperTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE(@"333333")] objectForKey:@"numberTextColor"];
    [[[d stub] andReturnValue:OCMOCK_VALUE(@"444444")] objectForKey:@"lowerTextColor"];
    
    self.mvc.colorPasswordText = YES;
    [self.mvc.passwordField setStringValue:@"cC#2"];
    [self.mvc controlTextDidChange:mockNotification];
    attrStr = [self.mvc.passwordField attributedStringValue];
    
    mismatch = YES;
    for (int i = 0; i < testStr.length ; i++) {
        NSDictionary *a1, *a2;
        a1 = [attrStr attributesAtIndex:i effectiveRange:nil];
        a2 = [testStr attributesAtIndex:i effectiveRange:nil];
        if ([a1 isEqualTo:a2]) {
            mismatch = NO;
            break;
        }
    }
    XCTAssertTrue(mismatch, @"Password field is highlighted when it should be");
    [defaultsMock stopMocking];
    [d stopMocking];
    
}
- (void)testManualChangePasswordField {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    //returning password field for object propery
    [[[mockNotification stub] andReturn:self.mvc.passwordField] object];
    
    //testing pattern change
    [self.mvc.passwordField setStringValue:@"c"];
    [self.mvc controlTextDidChange:mockNotification];
    float currStrength = self.mvc.passwordStrengthLevel.floatValue;
    
    [self.mvc.passwordField setStringValue:@"!@#$%$#@@#$"];
    [self.mvc controlTextDidChange:mockNotification];
    XCTAssertTrue(currStrength != self.mvc.passwordStrengthLevel.floatValue, @"Password strength did not update when passwordField is entered manually");
}
-(void)testDefaultsBindingsRandom {

    [self deleteUserDefaults];
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];

    [self validateCheckboxDefaults:self.mvc.useSymbols defaultsKey:@"randomUseSymbols"];
    [self validateCheckboxDefaults:self.mvc.avoidAmbiguous defaultsKey:@"randomAvoidAmbiguous"];
    [self validateCheckboxDefaults:self.mvc.mixedCase defaultsKey:@"randomMixedCase"];
    
    [self validateSliderDefaults:self.mvc.passwordLengthSliderRandom defaultsKey:@"passwordLength"];

}
-(void)testBindingsPattern {
    
    return; //for some reason the text binding isn't updating
    
    [self deleteUserDefaults];
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:1];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    [self.mvc.patternText setStringValue:@"abc"];
//    [self.mvc.patternText performClick:self];
    
    NSDictionary *bindingInfo = [self infoForBinding:NSValueBinding];
    [[bindingInfo valueForKey:NSObservedObjectKey] setValue:self.mvc.patternText
                                                 forKeyPath:[bindingInfo valueForKey:NSObservedKeyPathKey]];
    
    XCTAssertTrue([[d stringForKey:@"userPattern"] isEqualToString:@"abc"],@"userPattern should update to abc is %@",[d stringForKey:@"userPattern"]);
    
}
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
-(void)validateSliderDefaults:(NSSlider *)slider
                  defaultsKey:(NSString *)key {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    self.mvc.passwordLengthSliderRandom.integerValue = 22;
    [self.mvc.passwordLengthSliderRandom performClick:self];
    XCTAssertEqual([d floatForKey:key], 22, @"%@ slider should update defaults to 22",key);
    
    self.mvc.passwordLengthSliderRandom.integerValue = 12;
    [self.mvc.passwordLengthSliderRandom performClick:self];
    XCTAssertEqual([d floatForKey:key], 12, @"%@ slider should update defaults to 22",key);
}
-(void)validateCheckboxDefaults:(NSButton *)checkbox
                    defaultsKey:(NSString *)key {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    checkbox.state = YES;
    [checkbox performClick:self];
    XCTAssertFalse([d boolForKey:key], @"Checkbox %@ should save to defaults as NO",key);
    [checkbox performClick:self];
    XCTAssertTrue([d boolForKey:key], @"Checkbox %@ should save to defaults as YES",key);
    
}
-(NSInteger)getSelectedPronounceableTag {
    NSButtonCell* selected = self.mvc.pronounceableSeparatorRadio.selectedCell;
    NSLog(@"TAG %ld",selected.tag);
    return selected.tag;
}
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
-(void)deleteUserDefaults {
    //delete current l
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
@end
