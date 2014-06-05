//
//  MasterViewControllerTest.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/14/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "MasterViewControllerTest.h"
#import "MasterViewController.h"
#import <OCMock/OCMock.h>
@interface MasterViewControllerTest ()
@property (nonatomic, strong) NSTimer  *clearClipboardTimer;
@end

@implementation MasterViewControllerTest

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}
//- (IBAction)copyToPasteboard:(id)sender {
//    id mockTimer = [OCMockObject mockForClass:[NSTimer class]];
//    [[mockTimer expect] scheduledTimerWithTimeInterval:1.0
//                                                target:[OCMArg any]
//                                              selector:[OCMArg anySelector]
//                                              userInfo:[OCMArg any]
//                                               repeats:YES];
//    [super copyToPasteboard:sender];
//    [mockTimer verify];
//    
//}
@end
