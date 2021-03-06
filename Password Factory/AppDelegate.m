//
//  AppDelegate.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindow.h"
#import "PreferencesViewController.h"
#import "DefaultsManager.h"
#import "StyleKit.h"
#import "constants.h"
#import "PasswordStorage.h"
#import "ExportViewController.h"
#import "MainWindowController.h"
#import "MenuPopover.h"
#import "Utilities.h"
#import "Password_Factory-Swift.h"
@import SBObjectiveCWrapper;

@interface AppDelegate()
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusMenu;
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, strong) NSEvent *popoverEvent;
@property (nonatomic, assign) BOOL showPrefs;
@property (nonatomic, strong) NSString *passwordToZoom;
@property (nonatomic, assign) BOOL launched;
@property (nonatomic, strong) MasterViewController *menuViewController;
@end
@implementation AppDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    [Logging setupLogging];
    [Utilities setRemoteStore];
    //set selector for url scheme that is called by the widget to go back to the app
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];
    //remove enter full screen menu item
    [[DefaultsManager get] setBool:NO forKey:@"NSFullScreenMenuItemEverywhere"];
    [self handleGetURLEvent:nil withReplyEvent:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    DefaultsManager *d = [DefaultsManager get];
    //enable touchbar
    if ([[NSApplication sharedApplication] respondsToSelector:@selector(isAutomaticCustomizeTouchBarMenuItemEnabled)]) {
        [NSApplication sharedApplication].automaticCustomizeTouchBarMenuItemEnabled = YES;
    }
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    MainWindowController *windowController;
    if (![d boolForKey:@"isMenuApp"]) {
        //load the main window controller if we are not a menu app
        windowController = [storyBoard instantiateControllerWithIdentifier:@"MainWindowController"];
        self.masterViewController = (MasterViewController *)windowController.window.contentViewController;
        self.currWindow = windowController.window;
    } else {
        //load the menu view controller if we are a menu app
        self.masterViewController = [storyBoard instantiateControllerWithIdentifier:@"MenuViewController"];
        //setting to menuViewController because that is a strong property, and it won't deallocate
        self.menuViewController = self.masterViewController;
    }
    if ((NSStringFromClass([NSTouchBar class]))) {
        self.masterViewController.touchBar = nil;
    }
    
    //init prefs window
    self.prefsWindowController = [storyBoard instantiateControllerWithIdentifier:@"PreferencesWindowController"];
    self.prefsViewController = (PreferencesViewController *)self.prefsWindowController.window.contentViewController;

    //init zoom window
    self.zoomWindowController = [storyBoard instantiateControllerWithIdentifier:@"ZoomWindowController"];
    self.zoomViewController = (ZoomViewController *)self.zoomWindowController.window.contentViewController;
    //init alert window
    self.alertWindowController = (AlertWindowController *)[storyBoard instantiateControllerWithIdentifier:@"AlertWindowController"];
    //set export window
    self.exportWindowController = [storyBoard instantiateControllerWithIdentifier:@"ExportWindowController"];
    
    //Set properties
    self.masterViewController.prefsWindowController = self.prefsWindowController;
    self.masterViewController.zoomWindowController = self.zoomWindowController;

    [self.prefsViewController resetShortcutRegistration]; //setting up global shortcut when app launches
    [self.prefsViewController changeLoginItem:nil]; //set the login item to the current state


    //doing magic for the app if it is in the menu
    if ([d boolForKey:@"isMenuApp"]) {
        //hiding the dock icon if specified
        if([d boolForKey:@"hideDockIcon"]) {
            [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
        }
        
        //Showing popover
        self.popover = [[MenuPopover alloc] init];
        self.popover.contentViewController = self.menuViewController;
        self.popover.contentSize = (CGSize)self.menuViewController.view.frame.size;
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
        self.popoverEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDown handler:^(NSEvent *event) {
           if (self.popover.shown) {
               if (event.window == nil) { //only close if we are not in our window
                   [self closePopover:event];
               }
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
        self.currWindow.restorable = YES;
    }
    //save window state
    [d setObject:@YES forKey:@"NSQuitAlwaysKeepsWindows"];
    
    //set the launched flag to true
    self.launched = YES;
    //show the prefs if we need to show them on launch
    if (self.showPrefs) {
        self.showPrefs = NO;
        [self loadPreferences:nil];
    }
    if (self.loadError) {
        [self.alertWindowController displayError:self.loadError[@"MESSAGE"] code:[(NSNumber *)self.loadError[@"CODE"] intValue]];
    }

}
-(void)applicationDidBecomeActive:(NSNotification *)notification {
    //show the zoomed password if we set one from the url scheme
    if(self.passwordToZoom) {
        [self.masterViewController zoomPassword:self.passwordToZoom];
        self.passwordToZoom = nil;
    }
}

-(void)application:(NSApplication *)application didReceiveRemoteNotification:(NSDictionary<NSString *,id> *)userInfo {
    CKNotification *n = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    [[PasswordStorage get] receivedUpdatedData:n complete:^(BOOL complete) {
        if (complete) {
            PFPasswordType currType = [self.masterViewController getSelectedPasswordType];
            if (currType == PFStoredType) {
                [self.masterViewController.currentPasswordTypeViewController.storedPasswordTable reloadData];
            }
        }
    }];
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
 Called when delete stored password is selected in the edit menu

 @param sender default sender
 */
- (IBAction)deleteStoredPassword:(NSMenuItem *)sender {
    [self.masterViewController deleteStoredPassword];
}
/**
 Called when an item in the tab menu is selected, and will switch to that tab

 @param sender default sender
 */
- (IBAction)selectTypeFromMenu:(NSMenuItem *)sender {
    [self.masterViewController selectPaswordType:(int)sender.tag];
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
    [self.masterViewController.passwordField setText:@""];

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
-(IBAction)exportPasswords:(id)sender {

    [self.exportWindowController showWindow:nil];
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
    DefaultsManager *d = [DefaultsManager get];
    PFPasswordType selected = [self.masterViewController getSelectedPasswordType];
    //If we are in the 'Tabs' menu, then disable the currently selected tab
    //TODO: don't use title because of localization
    if ([m.parentItem.title isEqualToString:@"Types"]) {
        //get the selected tab identifier
        
        //enable and disable Advanced and Stored based on settings
        if (m.tag == PFStoredType && selected != PFStoredType) {
            if ([d boolForKey:@"storePasswords"]) {
                return YES;
            } else {
                return NO;
            }
        }
        if (m.tag == PFAdvancedType && selected != PFAdvancedType) {
            if ([d boolForKey:@"enableAdvanced"]) {
                return YES;
            } else {
                return NO;
            }
        }
        //if we are on the currently selected item, disable the menu
        if(m.tag == selected) {
            return NO;
        }
    }
    //disable the 'Delete Stored Item' menu item unless we are on Stored
    if (m.tag == 901 && selected != PFStoredType) {
        return NO;
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

/**
 Loads the prefs window

 @param sender default sender
 */
- (IBAction)loadPreferences:(id)sender {
    [self.prefsWindowController showWindow:self];
}

-(void)zoomPassword:(NSString *)password {
    [self.masterViewController zoomPassword:password];
}
/**
 Will kill the app when the last window is closed if it is not a menu app, if it is, it will keep running

 @param sender default sender
 @return close state
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    //if it is a menuApp then don't kill app when window is closed
    return ![[DefaultsManager get] boolForKey:@"isMenuApp"];
}

/**
 Create the dock menu with the all the password types

 @param sender default sender
 @return dock menu
 */
- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
    NSMenu *dockMenu = [[NSMenu alloc] init];
    NSDictionary *allTypes = [self.masterViewController.password getFilteredPasswordTypes];
    PFPasswordType selected = [self.masterViewController getSelectedPasswordType];
    for(int i = 0; i < allTypes.count; i++) {
        PFPasswordType type = [self.masterViewController.password getPasswordTypeByIndex:i];
        NSString *name = [self.masterViewController.password getNameForPasswordType:type];
        NSMenuItem *m = [[NSMenuItem alloc] initWithTitle:name action:@selector(dockMenuItem:) keyEquivalent:@""];
        [dockMenu addItem:m];
        m.tag = type;
        m.identifier = name; //set the identifier to match the tab type
        //put a checkmark next to currently selected item
        if (selected == type) {
            [m setState:NSOnState];
        }
    }
    return dockMenu;
}

/**
 Called when dock menu item is clicked will select tab matching type and generate and copy (which will display a notification is set)

 @param sender default sender
 */
- (void)dockMenuItem:(NSMenuItem *)sender {
    [self.masterViewController selectPaswordType:sender.tag];
    [self.masterViewController generateAndCopy];
}


/**
 Called when the gear is pressed on the widget - it uses our url scheme to open the application if it is not running, or switch to it if it is active
 URL Schemes:
 com-cloud13-password-factory://settings - Opens Settings
 com-cloud13-password-factory://zoom?password=PASSWORD_TO_ZOOM - Zooms Password

 @param event default event
 @param replyEvent default replyEvent
 */
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString:urlString];
    BOOL showPreferences = [url.host isEqualToString:@"settings"];
    BOOL zoomPassword = [url.host isEqualToString:@"zoom"];
    if(showPreferences || zoomPassword) {
        if (self.launched) {
            if (showPreferences) {
                [self loadPreferences:nil];
                //Load up the main window as well
                if ([[DefaultsManager get] boolForKey:@"isMenuApp"]) {
                    [self showPopover:nil];
                } else {
                    [self.currWindow makeKeyAndOrderFront:self];
                }
            } else {
                //zoom password
                [self.masterViewController zoomPassword:[self getPasswordToZoomFromURL:urlString]];
            }

        } else {
            self.showPrefs = showPreferences;
            if (zoomPassword) {
                self.passwordToZoom = [self getPasswordToZoomFromURL:urlString];
            }
        }
        
    }
}

/**
 Gets the password to zoom from the url event

 @param urlString URL to check
 @return password to zoom
 */
-(NSString *)getPasswordToZoomFromURL:(NSString *)urlString {
    //get the query string from the url
    NSArray *queryItems = [[NSURLComponents alloc] initWithString:urlString].queryItems;
    if(queryItems) {
        //only checking the first to see if it matches 'password' because if it is not there then it didn't come from the app
        NSURLQueryItem *q = queryItems[0];
        if([q.name isEqualToString:@"password"]) {
            //found the query item, so zomm the password
            return q.value;
        }
    }
    return nil;
}
-(void)applicationWillTerminate:(NSNotification *)notification {
    if ([[DefaultsManager get] boolForKey:@"storePasswords"]) {
        [[PasswordStorage get] deleteOverMaxItems];
    }
}
@end
