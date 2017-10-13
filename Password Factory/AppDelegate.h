//
//  AppDelegate.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "MasterViewController.h"
#include "PreferencesWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong)  MasterViewController *masterViewController;
@property (nonatomic, strong)  PreferencesWindowController *prefsWindowController;


+(BOOL)isDarkMode;
@end
