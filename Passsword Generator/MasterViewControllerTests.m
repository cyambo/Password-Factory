//
//  MasterViewControllerTests.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/5/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "NSTimer+UnitTest.h"
#import "NSUSerDefaults+UnitTest.h"
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
    [self.mvc.patternText setStringValue:@"c"];
    [self.mvc controlTextDidChange:mockNotification];
    XCTAssertEqual(1, [self getPasswordFieldValue].length, @"Password length should be 1");
    
    [self.mvc.patternText setStringValue:@"cC\\C"];
    [self.mvc controlTextDidChange:mockNotification];
    XCTAssertEqual(3, [self getPasswordFieldValue].length, @"Password length should be 3");

}
-(BOOL)pronounceableRadioPress:(NSString *)toCompare tag:(int)tag {
    [self.mvc.pronounceableSeparatorRadio selectCellWithTag:tag];
    [self.mvc pressPrononunceableRadio:self.mvc.pronounceableSeparatorRadio];
    XCTAssertTrue([[self.mvc getPronounceableRadioSelected]
                   isEqualToString:toCompare],
                  @"Pronouneable radio should be %@ is %@",toCompare,[self.mvc getPronounceableRadioSelected]);
}
-(void)testPronounceable {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:2];
    
    [self.mvc.passwordLengthSliderPrononunceable setIntegerValue:5];
    [self.mvc changeLength:self.mvc.passwordLengthSliderPrononunceable];
    NSString *currPassword = [self getPasswordFieldValue];
    [self.mvc.passwordLengthSliderPrononunceable setIntegerValue:10];
    [self.mvc changeLength:self.mvc.passwordLengthSliderPrononunceable];
    XCTAssertNotEqual(currPassword, [self getPasswordFieldValue], @"Password not changed when pronounceable slider changed");
    XCTAssertTrue(currPassword.length < [self getPasswordFieldValue].length, @"Pronounceable length 5 not less than length 10");
    
    //testing radio mappings
    [self pronounceableRadioPress:@"None" tag:1];
    [self pronounceableRadioPress:@"Characters" tag:2];
    [self pronounceableRadioPress:@"Numbers" tag:3];
    [self pronounceableRadioPress:@"Symbols" tag:4];
    [self pronounceableRadioPress:@"Spaces" tag:5];
    [self pronounceableRadioPress:@"Hyphen" tag:0];
    currPassword = [self getPasswordFieldValue];
    //test if password is changed when radio is pressed
    for (int i=0; i<=5; i++) {
        [self.mvc.pronounceableSeparatorRadio selectCellWithTag:i];
        [self.mvc pressPrononunceableRadio:self.mvc.pronounceableSeparatorRadio];
        XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]], @"Password Field not updated when %@ radio is pressed",[self.mvc getPronounceableRadioSelected]);
        currPassword = [self getPasswordFieldValue];
    }
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
    NSString *currPassword = [self getPasswordFieldValue];
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:1];
    for(int i=0;i<3;i++) {
        [self.mvc.passwordTypeTab selectTabViewItemAtIndex:i];
        XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]],@"Password not changed when switched to tab %d",i);
        currPassword = [self getPasswordFieldValue];
    }
    
}
- (void)testGenerateButton {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    NSString *currPassword = [self getPasswordFieldValue];
    [self.mvc.generateButton performClick:self.mvc];
    XCTAssertTrue([currPassword isNotEqualTo:[self getPasswordFieldValue]],@"Pressing generate button does not regenerate new password");
}
- (void)testCopyToPasteboard {
    id timer = [NSTimer getTimer];
    NSInteger timerRetval = 3;
    [[timer expect] scheduledTimerWithTimeInterval:timerRetval
                                            target:[OCMArg any]
                                          selector:[OCMArg anySelector]
                                          userInfo:nil
                                           repeats:NO];
    [NSUserDefaults swapMethods];
    id d = [NSUserDefaults standardUserDefaults];

    [[[d stub] andReturnValue:OCMOCK_VALUE(timerRetval)] integerForKey:@"clearClipboardTime"];

    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    [self.mvc.pasteboardButton performClick:self.mvc];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *pbval = [pasteboard stringForType:NSPasteboardTypeString];

    XCTAssertNoThrow([timer verify], @"Timer not configured properly");
    XCTAssertTrue([pbval isEqualToString:[self getPasswordFieldValue]], @"Password not copied to pasteboard");
    [NSUserDefaults swapMethods];
  
}

- (void)testClipboardHandling {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];

    [self.mvc updatePasteboard:@"TO Copy To"];
    XCTAssertTrue([[pasteboard stringForType:NSPasteboardTypeString] isEqualToString:@"TO Copy To"], @"Text not copied to pasteboard");
    [self.mvc clearClipboard];
    XCTAssertTrue([[pasteboard stringForType:NSPasteboardTypeString] isEqualToString:@""], @"Pasteboard not cleard");
    
}
- (void)testUpdatePasswordField {
    id mockNotification = [OCMockObject mockForClass:[NSNotification class]];
    //returning password field for object propery
    [[[mockNotification stub] andReturn:self.mvc.passwordField] object];
    


    self.mvc.colorPasswordText = NO;
    [self.mvc.passwordField setStringValue:@"cC#2"];
    [self.mvc controlTextDidChange:mockNotification];
    NSAttributedString *attrStr = [self.mvc.passwordField attributedStringValue];
    //trying to get colors, not sure why I can't 
    unsigned int length;
    NSRange effectiveRange;
    NSColor *attributeValue;
    NSColor *b = [NSColor blackColor];
    
    length = attrStr.length;
    effectiveRange = NSMakeRange(0, 0);
    attributeValue =[attrStr attribute:NSForegroundColorAttributeName
               atIndex:0 effectiveRange:&effectiveRange];
//    NSLog(@"COLRO %@",attributeValue.colorSpace);

    
    
    
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
@end
