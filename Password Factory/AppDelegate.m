//
//  AppDelegate.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "AppDelegate.h"
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
    [PreferencesWindowController loadPreferencesFromPlist];
    
    self.prefsWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];

    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    self.masterViewController.prefsWindow = self.prefsWindowController;

    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView *)self.window.contentView).bounds;
    [self.prefsWindowController resetShortcutRegistration]; //setting up shortcut when app launches
    [self.prefsWindowController changeLoginItem:nil]; //set the login item to the current state
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
    } else {
        self.window.titlebarAppearsTransparent = YES;
        self.window.titleVisibility = NSWindowTitleHidden;
        self.window.styleMask |= NSFullSizeContentViewWindowMask;
        self.window.movableByWindowBackground = YES;
        //not a menu app so show the the window
        [self.window makeKeyAndOrderFront:self];
    }
    //save window state
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"NSQuitAlwaysKeepsWindows"];
    self.window.restorable = YES;
    
    self.launched = YES;

    if (self.showPrefs) {
        self.showPrefs = NO;
        [self loadPrefrences:nil];
    }
}
-(IBAction)togglePopover:(id)sender {
    if (self.popover.shown) {
        [self closePopover:sender];
    } else {
        [self showPopover:sender];
    }
}
- (IBAction)generatePasswordFromMenu:(id)sender {
    [self.masterViewController generatePassword];
}
- (IBAction)selectTabFromMenu:(NSMenuItem *)sender {
    //Maps tab titles to constants matching the tab index
    NSDictionary *tabSelect = @{@"Random" : @PFTabRandom, @"Pronounceable": @PFTabPronounceable, @"Passphrase": @PFTabPassphrase, @"Pattern": @PFTabPattern};
    if (tabSelect[sender.title] != nil) {
        [self.masterViewController.passwordTypeTab selectTabViewItemAtIndex:[tabSelect[sender.title] intValue]];
    }
}
-(void)disablePasswordTypeMenu:(int)selectedType {
//    NSMutableArray *menuTab = [NSMutableArray arrayWithCapacity:10];
//    [menuTab insertObject:self.randomMenuItem atIndex:PFTabRandom];
//    [menuTab insertObject:self.patternMenuItem atIndex:PFTabPattern];
//    [menuTab insertObject:self.pronounceableMenuItem atIndex:PFTabPronounceable];
//    [menuTab insertObject:self.passphraseMenuItem atIndex:PFTabPassphrase];
//
//
//
//    if(menuTab[selectedType]) {
//        NSMenuItem *m = menuTab[i];
//        m setAuto
//        for(int i = 0; i < menuTab.count; i++) {
//            if(i == selectedType) {
//                [(NSMenuItem *)menuTab[i] set\\\];
//            } else {
//                [(NSMenuItem *)menuTab[i] setEnabled:YES];
//            }
//        }
//    }
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
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    //if it is a menuApp then don't kill app when window is closed
    return ![[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"];
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
//This gets called when the gear is pressed on the widget
- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    if([url.host isEqualToString:@"settings"]) {
        if (self.launched) {
            [self loadPrefrences:nil];
            //Load up the main window as well 
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
                [self showPopover:nil];
            } else {
                [self.window makeKeyAndOrderFront:self];
            }
            
        } else {
            self.showPrefs = YES;
        }
        
    }
}
+(void)sendSupportEmail {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:support@password-factory.com"]];
}
#pragma mark Util
+(BOOL)isDarkMode {
    NSString *osxMode = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"];
    return [osxMode isEqualToString:@"Dark"];
}
@end
