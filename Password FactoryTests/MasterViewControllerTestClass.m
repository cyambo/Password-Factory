//
//  MasterViewControllerTest.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/14/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "MasterViewControllerTestClass.h"
#import "MasterViewController.h"
#import <OCMock/OCMock.h>
@interface MasterViewControllerTestClass ()
@property (nonatomic, strong) id  clearClipboardTimer;
@property (nonatomic, strong) Class timerClass;
@end

@implementation MasterViewControllerTestClass

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.

    }
    return self;
}

@end