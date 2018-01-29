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
#import "ZoomViewController.h"
#import "AlertWindowController.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>


@property (nonatomic, strong) NSWindow *currWindow;
@property (nonatomic, strong) MasterViewController *masterViewController;
@property (nonatomic, strong) PreferencesViewController *prefsViewController;
@property (nonatomic, strong) NSWindowController *prefsWindowController;
@property (nonatomic, strong) ZoomViewController *zoomViewController;
@property (nonatomic, strong) NSWindowController *zoomWindowController;
@property (nonatomic, strong) AlertWindowController *alertWindowController;
@property (nonatomic, strong) NSWindowController *exportWindowController;
@property (nonatomic, strong) NSDictionary *loadError;
- (IBAction)generatePasswordFromMenu:(id)sender;
- (IBAction)selectTypeFromMenu:(NSMenuItem *)sender;
- (IBAction)deleteStoredPassword:(NSMenuItem *)sender;


@property (weak) IBOutlet NSMenuItem *randomMenuItem;
@property (weak) IBOutlet NSMenuItem *patternMenuItem;
@property (weak) IBOutlet NSMenuItem *pronounceableMenuItem;
@property (weak) IBOutlet NSMenuItem *passphraseMenuItem;
@property (weak) IBOutlet NSMenuItem *advancedMenuItem;
@property (weak) IBOutlet NSMenuItem *storedMenuItem;


- (IBAction)exportPasswords:(id)sender;
- (IBAction)contactSupport:(id)sender;
- (IBAction)menuCopy:(id)sender;
- (IBAction)menuCut:(id)sender;
- (IBAction)loadPreferences:(id)sender;
@end
