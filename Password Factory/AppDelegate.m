//
//  AppDelegate.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusBarType.h"
#import "PreferencesWindowController.h"
#import "StyleKit.h"
@interface AppDelegate()
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusMenu;
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, strong) NSEvent *popoverEvent;
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
    [self.prefsWindowController resetShortcutRegistration]; //setting up shortcut when app launches
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
        
        //hiding the dock icon if specified
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"hideDockIcon"]) {
            [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        }
        // Chooses which type of status menu we use, because each type had random bugs or crashers
        // And I wanted to be able to switch between the three types, Window, Menu and Popover for testing
        switch (STATUS_MENU_TYPE) {
            case PFStatusWindow: //uses view as dropdown
                {
                    [self.window setStyleMask:NSBorderlessWindowMask];
                    SEL closeSelector = @selector(closePopover:);
                    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
                    
                    
                    //registering for notifications so window can be hidden when clicked outside of window
                    [notification addObserver:self
                                     selector:closeSelector
                                         name:NSWindowDidResignKeyNotification
                                       object:self.window];
                    
                    [notification addObserver:self
                                     selector:closeSelector
                                         name:NSWindowDidResignMainNotification
                                       object:self.window];
                    
                    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
                    self.statusView = [[StatusView alloc] initWithMvc:self.masterViewController]; //square
                    
            
                    [self.statusItem setView:self.statusView];
                }
                break;
            case PFStatusMenu: //uses menu for dropdown
                {
                    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
                    self.statusItem.title = @"";
                    NSImage *statusImage = [StyleKit imageOfMenuIcon];
                    [statusImage setTemplate:YES]; //setting it as a template will automatically change it based upon menu appearance, ie dark mode
                    self.statusItem.image = statusImage;
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
                    self.popover = [[NSPopover alloc] init];
                    self.popover.contentViewController = self.masterViewController;
                    self.popover.contentSize = (CGSize)self.masterViewController.view.frame.size;
                    self.popover.behavior = NSPopoverBehaviorTransient;
                    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
                    
                    NSImage *statusImage = [StyleKit imageOfMenuIcon];
                    [statusImage setTemplate:YES]; //setting it as a template will automatically change it based upon menu appearance, ie dark mode
                    self.statusItem.button.image = statusImage;
                    self.statusItem.highlightMode = YES;

                    
                    self.statusItem.button.action = @selector(togglePopover:);
                    
                    //Registering for events so the popover can be closed when we click outside the window
                    self.popoverEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDown
                                                                               handler:^(NSEvent *event) {
                                                                                   if (self.popover.shown) {
                                                                                       [self closePopover:event];
                                                                                   }
                    }];
                }
                break;

        }
        
    } else {
        self.window.titlebarAppearsTransparent = YES;
        self.window.titleVisibility = NSWindowTitleHidden;
        self.window.styleMask |= NSFullSizeContentViewWindowMask;
        self.window.movableByWindowBackground = YES;
        //not a menu app so show the the window
        [self.window makeKeyAndOrderFront:self];
    }


}
-(IBAction)togglePopover:(id)sender {
    if (self.popover.shown) {
        [self closePopover:sender];
    } else {
        [self showPopover:sender];
    }
    
}
-(void)showPopover:(id)sender {
    NSButton *b = (NSButton *)self.statusItem.button;
    [self.popover showRelativeToRect:b.bounds ofView:self.statusItem.button preferredEdge:NSRectEdgeMinY];
}
-(void)closePopover:(id)sender {
    [self.popover performClose:sender];
}
-(void)applicationWillTerminate:(NSNotification *)notification {
    //Sync preferences when closing
    [PreferencesWindowController syncSharedDefaults];
}


- (IBAction)loadPrefrences:(id)sender {
    [self.prefsWindowController showWindow:self];
    
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    //if it is a menuApp then don't kill app when window is closed
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"];
}

-(void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    if([url.host isEqualToString:@"settings"]) {
        [self loadPrefrences:nil];
    }
}

#pragma mark Util
+(BOOL)isDarkMode {
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    return [osxMode isEqualToString:@"Dark"];
}
@end
