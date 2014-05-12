//
//  MasterViewControllerTests.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/5/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MasterViewController.h"
@interface MasterViewControllerTests : XCTestCase
@property (nonatomic, strong) MasterViewController *mvc;
@end

@implementation MasterViewControllerTests

- (void)setUp
{
    [super setUp];
    self.mvc = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    [self.mvc view];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRandom {
    [self.mvc.passwordTypeTab selectTabViewItemAtIndex:0];
    NSArray *checks = @[self.mvc.useSymbols,self.mvc.avoidAmbiguous,self.mvc.mixedCase];
    int i = 0;
    for (NSButton *b in checks){
        NSString *p = [self.mvc.passwordField stringValue];
        [b performClick:self];
        XCTAssertNotEqual(p, [self.mvc.passwordField stringValue], @"Checkbox %@ failed to change value",b.title);
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
    
    XCTAssertEqual(5, [self.mvc.passwordField stringValue].length, @"Password not changed to 5");
    XCTAssertEqual(5, self.mvc.passwordLengthLabelPronounceable.intValue, @"Random password length label not changed to 5 it is %@",self.mvc.passwordLengthLabelPronounceable.stringValue);
    
    //checking random password length setter min
    //the min is 5 and if you make a setter less than 5 it will be 5
    [self.mvc.passwordLengthSliderRandom setIntegerValue:4];
    [self.mvc changeLength:self.mvc.passwordLengthSliderRandom];
    ;
    XCTAssertEqual(5, [self.mvc.passwordField stringValue].length, @"Password not changed to 5");
    XCTAssertEqual(5, self.mvc.passwordLengthLabelPronounceable.intValue, @"Random Password length label should be 5 it is %@",self.mvc.passwordLengthLabelPronounceable.stringValue);
    
    //checking random password length setter max
    //the max is 40 and if you make a setter more than 40 it will be 40
    [self.mvc.passwordLengthSliderRandom setIntegerValue:41];
    [self.mvc changeLength:self.mvc.passwordLengthSliderRandom];
    ;
    XCTAssertEqual(40, [self.mvc.passwordField stringValue].length, @"Password not changed to 40");
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
    XCTAssertEqual(1, self.mvc.passwordField.stringValue.length, @"Password length should be 1");
    
    [self.mvc.patternText setStringValue:@"cC\\C"];
    [self.mvc controlTextDidChange:mockNotification];
    XCTAssertEqual(3, self.mvc.passwordField.stringValue.length, @"Password length should be 3");

}
@end
