//
//  MasterViewControllerTests.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/5/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MasterViewController.h"
@interface MasterViewControllerTests : XCTestCase
@property (nonatomic, strong) MasterViewController *mvc;
@end

@implementation MasterViewControllerTests

- (void)setUp
{
    [super setUp];
    self.mvc = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



@end
