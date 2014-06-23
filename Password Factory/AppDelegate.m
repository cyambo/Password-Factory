//
//  AppDelegate.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusBarType.h"

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

        switch (STATUS_MENU_TYPE) {
            case PFStatusWindow: //uses view as dropdown
                {
                    [self.window setStyleMask:NSBorderlessWindowMask];
                    SEL closeSelector = @selector(closeWindow);
                    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
                    
                    
                    //registering for notifications so window can be hidden when clicked outside of window
                    [notification addObserver:self
                                     selector:closeSelector
                                         name:NSWindowDidResignKeyNotification
                                       object:[self window]];
                    
                    [notification addObserver:self
                                     selector:closeSelector
                                         name:NSWindowDidResignMainNotification
                                       object:[self window]];
                    
                    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
                    self.statusView = [[StatusView alloc] initWithMvc:self.masterViewController]; /* square item */
                    
                    
            
                    [self.statusItem setView:self.statusView];
                }
                break;
            case PFStatusMenu: //uses menu for dropdown
                {
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
                }
                break;
            case PFStatusPopover:
                {
                    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
                    self.statusView = [[StatusView alloc] initWithMvc:self.masterViewController]; /* square item */
                    [self.statusItem setView:self.statusView];
                }
                break;

        }

        
        
        
        

        

        
    } else {
        //not a menu app so show the the window
        [self.window makeKeyAndOrderFront:self];
    }

    

}
-(void)closeWindow {
    [self.window close];
    [self.statusView setNeedsDisplay:YES];
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
