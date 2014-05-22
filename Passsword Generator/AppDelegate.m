//
//  AppDelegate.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate()
@property (nonatomic, strong) NSStatusItem *statusItem;
@end
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [PreferencesWindowController loadPreferencesFromPlist];
    // Insert code here to initialize your application
    self.prefsWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];

    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    self.masterViewController.prefsWindow = self.prefsWindowController;
    if (0) {
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.title = @"Test";
        self.statusItem.highlightMode = YES;
        
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
    return YES;
}
@end
