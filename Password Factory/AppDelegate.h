//
//  AppDelegate.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "MasterViewController.h"
#include "PreferencesViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (nonatomic, weak) NSWindow *currWindow;
@property (nonatomic, weak) MasterViewController *masterViewController;
@property (nonatomic, weak) PreferencesViewController *prefsViewController;
@property (nonatomic, weak) NSWindowController *prefsWindowController;
- (IBAction)generatePasswordFromMenu:(id)sender;
- (IBAction)selectTypeFromMenu:(NSMenuItem *)sender;
@property (weak) IBOutlet NSMenuItem *randomMenuItem;
@property (weak) IBOutlet NSMenuItem *patternMenuItem;
@property (weak) IBOutlet NSMenuItem *pronounceableMenuItem;
@property (weak) IBOutlet NSMenuItem *passphraseMenuItem;
- (IBAction)contactSupport:(id)sender;
- (IBAction)menuCopy:(id)sender;
- (IBAction)menuCut:(id)sender;

+(BOOL)isDarkMode;
@end
