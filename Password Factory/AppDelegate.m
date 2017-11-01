//
//  AppDelegate.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindow.h"
#import "PreferencesWindowController.h"
#import "StyleKit.h"
#import "constants.h"

@interface AppDelegate()
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusMenu;
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, strong) NSEvent *popoverEvent;
@property (nonatomic, assign) BOOL showPrefs;
@property (nonatomic, assign) BOOL launched;

@end
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //load default preferences from our plist
    [PreferencesWindowController loadPreferencesFromPlist];
    //init prefs window
    self.prefsWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
    
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSWindowController *windowController = [storyBoard instantiateControllerWithIdentifier:@"MainWindowController"];
    
    //Set properties
    self.currWindow = windowController.window;
    self.masterViewController = (MasterViewController *)windowController.window.contentViewController;
    self.masterViewController.prefsWindow = self.prefsWindowController;

    [self.prefsWindowController resetShortcutRegistration]; //setting up global shortcut when app launches
    [self.prefsWindowController changeLoginItem:nil]; //set the login item to the current state
    //doing magic for the app if it is in the menu
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
        //hiding the dock icon if specified
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"hideDockIcon"]) {
            [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        }
        
        //Showing popover
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = self.masterViewController;
        self.popover.contentSize = (CGSize)self.masterViewController.view.frame.size;
        self.popover.behavior = NSPopoverBehaviorTransient;
        //setting the status bar size
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        //getting the status image
        NSImage *statusImage = [StyleKit imageOfMenuIcon];
        [statusImage setTemplate:YES]; //setting it as a template will automatically change it based upon menu appearance, ie dark mode
        self.statusItem.button.image = statusImage;
        self.statusItem.highlightMode = YES;
        //set the action when clicking menu item
        self.statusItem.button.action = @selector(togglePopover:);
        
        //Registering for events so the popover can be closed when we click outside the window
        self.popoverEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDown
                                                                   handler:^(NSEvent *event) {
                                                                       if (self.popover.shown) {
                                                                           [self closePopover:event];
                                                                       }
        }];
    } else {
        //set window appearance and settings
        self.currWindow.titlebarAppearsTransparent = YES;
        self.currWindow.titleVisibility = NSWindowTitleHidden;
        self.currWindow.styleMask |= NSFullSizeContentViewWindowMask;
        self.currWindow.movableByWindowBackground = YES;
        //not a menu app so show the the window
        [windowController showWindow:self];
    }
    //save window state
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"NSQuitAlwaysKeepsWindows"];
    self.currWindow.restorable = YES;
    
    //set the launched flag to true
    self.launched = YES;
    //show the prefs if we need to show them on launch
    if (self.showPrefs) {
        self.showPrefs = NO;
        [self loadPrefrences:nil];
    }
}

/**
 Toggles the display of the popover in the menu app

 @param sender default sender
 */
-(IBAction)togglePopover:(id)sender {
    if (self.popover.shown) {
        [self closePopover:sender];
    } else {
        [self showPopover:sender];
    }
}

/**
 Called when the generate menu item is selected and will generate a new password

 @param sender default sender
 */
- (IBAction)generatePasswordFromMenu:(id)sender {
    [self.masterViewController generatePassword];
}

/**
 Called when an item in the tab menu is selected, and will switch to that tab

 @param sender default sender
 */
- (IBAction)selectTabFromMenu:(NSMenuItem *)sender {
    [self selectTabByTag:(int)sender.tag];
}

/**
 Selects the tab in the main window by tag id

 @param tag tag number of tab
 */
-(void)selectTabByTag:(int)tag {
    //the tag of the menu item matches the identifier of the tabs so we can
    //just use the tag to select the proper tab
    if (tag >= 0) {
        [self.masterViewController.passwordTypeTab selectTabViewItemAtIndex:tag];
    }
}

/**
 Called when the user presses copy on the menu
 It will determine if there is anything selected in any text box, and if it is selected, it will copy that
 If nothing is selected, it will copy the password displayed to the clipboard

 @param sender default sender
 */
-(IBAction)menuCopy:(id)sender {
    //get the first responder
    NSResponder *fr = [self.currWindow firstResponder];
    //see if we are a text view
    if ([fr isKindOfClass:[NSTextView class]]) {
        //if anything has a selection send copy to the first responder
        if ([self hasSelectionInTextView:(NSTextView *)fr]) {
            [(NSTextView *)fr copy:self];
            return;
        }
    }
    //otherwise copy the password to the clipboard
    [self.masterViewController copyToClipboard:self];
}
-(IBAction)menuCut:(id)sender {
    //get the first responder
    NSResponder *fr = [self.currWindow firstResponder];
    //see if we are a text view
    if ([fr isKindOfClass:[NSTextView class]]) {
        //if anything has a selection send copy to the first responder
        if ([self hasSelectionInTextView:(NSTextView *)fr]) {
            [(NSTextView *)fr cut:self];
            return;
        }
    }
    //otherwise copy the password to the clipboard
    [self.masterViewController copyToClipboard:self];
    //empty the password field
    [self.masterViewController.passwordField setStringValue:@""];

}

-(BOOL)hasSelectionInTextView:(NSTextView *)textView {
    NSArray *ranges = [textView selectedRanges]; //get the selection
    for(int i = 0; i < ranges.count; i++) { //go through all the possible selections and if any has anything in it set hasSelection
        if([ranges[i] rangeValue].length > 0) {
            return true;
        }
    }
    return false;
}

/**
 Sends an email to support

 @param sender default sender
 */
- (IBAction)contactSupport:(id)sender {
    NSString *mailto = [NSString stringWithFormat:@"mailto:%@",SupportEmailAddress];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailto]];
}
/**
 Called to show and hide menu items when they are shown

 @param item default item
 @return the menu display status
 */
- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item {

    NSMenuItem *m = (NSMenuItem *)item;
    //If we are in the 'Tabs' menu, then disable the currently selected tab
    if ([m.parentItem.title isEqualToString:@"Tabs"]) {
        //get the selected tab identifier
        int selected = [[self.masterViewController passwordTypeTab].selectedTabViewItem.identifier intValue];
        //the tab identifier and menu item tag match up
        if(m.tag == selected) {
            return NO;
        }
    }
    //otherwise, enable the menu
    return YES;
}

/**
 Show the popover when the menu item is clicked

 @param sender default sender
 */
-(void)showPopover:(id)sender {
    NSButton *b = (NSButton *)self.statusItem.button;
    [self.popover showRelativeToRect:b.bounds ofView:self.statusItem.button preferredEdge:NSRectEdgeMinY];
}

/**
 Close the popover when clicking outside window

 @param sender default sender
 */
-(void)closePopover:(id)sender {
    [self.popover performClose:sender];
}
-(void)applicationWillTerminate:(NSNotification *)notification {
    //Sync preferences when closing
    [PreferencesWindowController syncSharedDefaults];
}

/**
 Loads the prefs window

 @param sender default sender
 */
- (IBAction)loadPrefrences:(id)sender {
    [self.prefsWindowController showWindow:self];
}

/**
 Will kill the app when the last window is closed if it is not a menu app, if it is, it will keep running

 @param sender default sender
 @return close state
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    //if it is a menuApp then don't kill app when window is closed
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"];
}

/**
 Create the dock menu with the four password types

 @param sender default sender
 @return dock menu
 */
- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
    NSMenu *dockMenu = [[NSMenu alloc] init];
    NSArray *types = @[@"Random", @"Pattern", @"Pronounceable", @"Passphrase"];
    for(int i = 0; i < types.count; i++) {
        NSMenuItem *m = [[NSMenuItem alloc] initWithTitle:types[i] action:@selector(dockMenuItem:) keyEquivalent:@""];
        [dockMenu addItem:m];
        m.tag = -1; //setting a tag of -1 enables it
        m.identifier = @(i).stringValue; //set the identifier to match the tab type
    }
    return dockMenu;
}

/**
 Called when dock menu item is clicked will select tab matching type and generate and copy (which will display a notification is set)

 @param sender default sender
 */
- (void)dockMenuItem:(NSMenuItem *)sender {
    [self selectTabByTag:[sender.identifier intValue]];
    [self.masterViewController generateAndCopy];
}
-(void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    //set selector for url scheme that is called by the widget to go back to the app
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];
    //remove enter full screen menu item
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NSFullScreenMenuItemEverywhere"];
}

/**
 Called when the gear is pressed on the widget - it uses our url scheme to open the application if it is not running, or switch to it if it is active

 @param event default event
 @param replyEvent default replyEvent
 */
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    if([url.host isEqualToString:@"settings"]) {
        if (self.launched) {
            [self loadPrefrences:nil];
            //Load up the main window as well 
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
                [self showPopover:nil];
            } else {
                [self.currWindow makeKeyAndOrderFront:self];
            }
            
        } else {
            self.showPrefs = YES;
        }
        
    }
}
#pragma mark Util

/**
 Static method that returns the dark mode state

 @return yes if it is dark, no if it isnt
 */
+(BOOL)isDarkMode {
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    return [osxMode isEqualToString:@"Dark"];
}
@end
