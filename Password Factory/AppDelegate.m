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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [PreferencesWindowController loadPreferencesFromPlist];

    self.prefsWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];

    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    self.masterViewController.prefsWindow = self.prefsWindowController;

    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView *)self.window.contentView).bounds;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
        //building the status item
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        self.statusItem.title = @"";
        
        self.statusItem.image = [NSImage imageNamed:@"menu-icon"];
        self.statusItem.alternateImage = [NSImage imageNamed:@"menu-icon-inv"];
        self.statusItem.highlightMode = YES;
        self.statusMenu = [[NSMenu alloc] initWithTitle:@""];
        self.statusMenu.autoenablesItems = YES;
        [self.statusItem setAction:@selector(statusClick:)];
        [self.statusItem setTarget:self];
        
        //setting up the window and window notifications
       [self.window setStyleMask:NSBorderlessWindowMask];
        
        
        SEL closeSelector = @selector(closeWindow);
        NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];

        
        //registering for notifications so window can be hidden
        [notification addObserver:self
                      selector:closeSelector
                          name:NSWindowDidResignKeyNotification
                        object:[self window]];
        
        [notification addObserver:self
                      selector:closeSelector
                          name:NSWindowDidResignMainNotification
                        object:[self window]];

        
    } else {
        //not a menu app so show the the window
        [self.window makeKeyAndOrderFront:self];
    }

    

}
- (void)closeWindow {
    [self.window close];
}
- (void)statusClick:(id)sender {
    if (self.window.isVisible) {
        [self closeWindow];
    } else {
    
        //getting coordinates of status menu so I can place the window under it
        CGRect eventFrame = [[[NSApp currentEvent] window] frame];
        eventFrame.size = self.window.frame.size;
        
        [self.window setFrame:eventFrame display:YES];
        [NSApp activateIgnoringOtherApps:YES];
        [self.window makeKeyAndOrderFront:self];
    }
    


}
- (IBAction)loadPrefrences:(id)sender {
    [self.prefsWindowController showWindow:self];
    
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    //if it is a menuApp then don't kill app when window is closed
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"];
}
@end
