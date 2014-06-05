//
//  AppDelegate.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate()
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusMenu;
@end
@implementation AppDelegate
static BOOL isMenu;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [PreferencesWindowController loadPreferencesFromPlist];
    // Insert code here to initialize your application
    self.prefsWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];

    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    self.masterViewController.prefsWindow = self.prefsWindowController;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        self.statusItem.title = @"";
        
        self.statusItem.image = [NSImage imageNamed:@"menu-icon"];
        self.statusItem.alternateImage = [NSImage imageNamed:@"menu-icon-inv"];
        self.statusItem.highlightMode = YES;
        self.statusMenu = [[NSMenu alloc] initWithTitle:@""];
        self.statusMenu.autoenablesItems = NO;
        

        NSMenuItem* statusMenuItem;
        statusMenuItem = [[NSMenuItem alloc]
                   initWithTitle:@""
                   action:nil
                   keyEquivalent:@""];
        [statusMenuItem setView: self.masterViewController.view];
        [statusMenuItem setTarget:self];
        [self.statusMenu addItem:statusMenuItem];
        
        
        self.statusItem.menu = self.statusMenu;
        
    } else {
        [self.window.contentView addSubview:self.masterViewController.view];
        self.masterViewController.view.frame = ((NSView *)self.window.contentView).bounds;
        [self.window makeKeyAndOrderFront:self];
    }

    

}

- (IBAction)loadPrefrences:(id)sender {
    [self.prefsWindowController showWindow:self];
    
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"];
}
@end
