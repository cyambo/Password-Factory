//
//  PreferencesWindowTests.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/14/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PreferencesWindow.h"
@interface PreferencesWindowTests : XCTestCase
@property (nonatomic, strong) PreferencesWindow *pw;
@end

@implementation PreferencesWindowTests

- (void)setUp
{
    [super setUp];
    self.pw = [[PreferencesWindow alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoadPreferencesFromPlist
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSDictionary *p = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    //delete current nsuserdefaults
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    //nothing should be set
    for (NSString *k in p) {

        XCTAssertNil([d objectForKey:k], @"Key '%@' set when it should be nil",k);

    }
    [self.pw loadPreferencesFromPlist];
    
    for (NSString *k in p) {
        
        XCTAssertNotNil([d objectForKey:k], @"Key '%@' nil when it should be set",k);
        
    }
}

@end
