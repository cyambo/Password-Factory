//
//  PreferencesWindowTests.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/14/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSColor+NSColorHexadecimalValue.h"
#import "PreferencesWindowController.h"

@interface PreferencesWindowTests : XCTestCase
@property (nonatomic, strong) PreferencesWindowController *pw;
@end

@implementation PreferencesWindowTests

- (void)setUp
{
    [super setUp];
    if (self.pw == nil) {
        self.pw = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
        [self.pw showWindow:self];
    }

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [self.pw.window orderOut:self];
}
-(void)deleteUserDefaults {
    //delete current nsuserdefaults
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
- (void)testLoadPreferencesFromPlist
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSDictionary *p = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    [self deleteUserDefaults];
    
    //nothing should be set
    for (NSString *k in p) {

        XCTAssertNil([d objectForKey:k], @"Key '%@' set when it should be nil",k);

    }
    [PreferencesWindowController getPrefsFromPlist];
    
    for (NSString *k in p) {
        
        XCTAssertNotNil([d objectForKey:k], @"Key '%@' nil when it should be set",k);
        
    }
}
-(void)testChangeColor {
    NSDictionary *wells = @{
                            @"upperTextColor":  self.pw.uppercaseTextColor,
                            @"lowerTextColor":  self.pw.lowercaseTextColor,
                            @"symbolTextColor": self.pw.symbolsColor,
                            @"numberTextColor": self.pw.numbersColor};
    NSColor *c = [NSColor greenColor];
    NSString *cHex = [c hexadecimalValueOfAnNSColor];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    for(NSString *k in wells) {
        NSColorWell *well = [wells objectForKey:k];
        [well setColor:c];
        [self deleteUserDefaults];
        [self.pw changeColor:well];
        XCTAssertTrue([cHex isEqualToString: [d objectForKey:k]], @"Color well '%@' not updated",k);
    }
}
-(void)testSlider {
    //put test to test slider to label bindings
}
-(void)testBindings {
    [self validateCheckBindings:self.pw.colorPasswordText defaultsKey:@"colorPasswordText" boundTo:@[self.pw.uppercaseTextColor,self.pw.lowercaseTextColor,self.pw.symbolsColor, self.pw.numbersColor] top:nil];
    [self validateCheckBindings:self.pw.enableGlobalHotkey defaultsKey:@"MASPGShortcutEnabled" boundTo:@[self.pw.displayNotification, self.pw.playNotificationSound] top:nil];
    [self validateCheckBindings:self.pw.automaticallyClearClipboard defaultsKey:@"clearClipboard" boundTo:@[self.pw.clearTime] top:nil];
    [self validateCheckBindings:self.pw.displayNotification defaultsKey:@"globalHotkeyShowNotification" boundTo:nil top:self.pw.enableGlobalHotkey];
    [self validateCheckBindings:self.pw.playNotificationSound defaultsKey:@"globalHotkeyPlaySound" boundTo:nil top:self.pw.enableGlobalHotkey];
    

}
-(void)validateCheckBindings:(NSButton *)checkBox defaultsKey:(NSString *)defaultsKey boundTo:(NSArray *)bound top:(NSButton *)top {
    [self deleteUserDefaults];
    if(top) {
        top.state = NO;
        [top performClick:self];
    }
    checkBox.state = YES;
    [checkBox performClick:self];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

    XCTAssertFalse([d boolForKey:defaultsKey], @"Checkbox %@ did not update defaults",defaultsKey);
    [self validateBindings:NO bound:bound name:defaultsKey];
    [checkBox performClick:self];
    XCTAssertTrue([d boolForKey:defaultsKey], @"Checkbox %@ did not update defaults",defaultsKey);
    [self validateBindings:YES bound:bound name:defaultsKey];
}
-(void)validateBindings:(BOOL)enabled bound:(NSArray *)bound name:(NSString *)name{
    for(NSControl *b in bound) {

        XCTAssertEqual(enabled, [b isEnabled], @"%@ isEnabled should be %d",name,[b isEnabled]);
    }
}
@end
