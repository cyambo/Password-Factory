//
//  AppDelegate.h
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "MasterViewController.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong)  MasterViewController *masterViewController;

@end
