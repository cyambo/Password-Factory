//
//  PreferencesWindowController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "NSColor+NSColorHexadecimalValue.h"
#import "AppDelegate.h"
#import "DefaultsManager.h"

NSString *const MASPreferenceKeyShortcut = @"MASPGShortcut";
NSString *const MASPreferenceKeyShortcutEnabled = @"MASPGShortcutEnabled";

@implementation PreferencesWindowController 

__weak id _constantShortcutMonitor;
static BOOL loadedPrefs;
static NSDictionary *prefsPlist;

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {

    }
    return self;
}
- (void)awakeFromNib {

    [PreferencesWindowController loadPreferencesFromPlist];
    [self updatePrefsUI];
    [self setObservers];
    
    //setup shortcut handler
    [self.shortcutView bind:@"enabled" toObject:[NSUserDefaults standardUserDefaults] withKeyPath:MASPreferenceKeyShortcutEnabled options:nil];
    
    // Shortcut view will follow and modify user preferences automatically
    self.shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;
    
    //setting up window close notification
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    
    //registering for notification that the window is closing to run shortcut set code
    //this is because it seems to 'forget' the key when preferences is loaded
    [notification addObserver:self
                     selector:@selector(resetShortcutRegistration)
                         name:NSWindowWillCloseNotification
                       object:self.window];
    
    //setting the initial checkbox states for the menu and dock checkboxes to an unset state
    self.initialMenuState = 2;
    self.initialDockState = 2;
    
    //initting login item
    self.loginItem = [[EMCLoginItem alloc] init];
}

/**
 Shows the window 

 @param default sender from IBOutlet
 */
-(void)showWindow:(id)sender {
    // Activate the global keyboard shortcut if it was enabled last time
    //moved to showWindow instead of awakeFromNib so that it will load everytime the window pops up
    [self resetShortcutRegistration];
    [super showWindow:sender];
    [self changeLoginItem:nil]; //runs every time the window is opened because the user can remove or add the login item from the prefs directly
}

#pragma mark observers
/**
 Sets the observers for the class
 */
-(void)setObservers {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    //sets the observer for the global shortcut key
    [d addObserver:self
        forKeyPath:MASPreferenceKeyShortcutEnabled
           options:NSKeyValueObservingOptionNew
           context:NULL];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //observing when the global shortcut is enabled
    if ([keyPath isEqualToString:MASPreferenceKeyShortcutEnabled]) {
        [self resetShortcutRegistration];
    }
}
#pragma mark prefs
/**
 Setup for the prefs window to fill in the set values
 */
-(void)updatePrefsUI {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    //Loading up the erase clipboard timer
    [self.clearTimeLabel setIntValue:(int)[d integerForKey:@"clearClipboardTime"]];
    
    //setting the color wells
    [self.uppercaseTextColor setColor: [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"upperTextColor"]]];
    [self.lowercaseTextColor setColor: [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"lowerTextColor"]]];
    [self.symbolsColor setColor: [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"symbolTextColor"]]];
    [self.numbersColor setColor: [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"numberTextColor"]]];
}
/**
 Makes sure our preferences are loaded only at launch
 */
+(void)loadPreferencesFromPlist {
    if (!loadedPrefs) {
        [PreferencesWindowController getPrefsFromPlist];
        loadedPrefs = YES;
    }

}
/**
 Loads our defaults.plist into a dictionary
 */
+(void)loadDefaultsPlist {
    if (prefsPlist == nil) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
        prefsPlist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"LOADED PREFS");
    }
}
/**
 Takes our defaults plist dictionary and merges it with standardUserDefaults so that our prefs are always set
 */
+ (void)getPrefsFromPlist {
    [PreferencesWindowController loadDefaultsPlist];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

    //taking plist and filling in defaults if none set
    for (NSString *k in prefsPlist) {
        if (![d objectForKey:k]) {
            [d setObject:[prefsPlist objectForKey:k] forKey:k];
            
        }
    }
    [PreferencesWindowController syncSharedDefaults];
}
/**
 Syncs our plist with the sharedDefaults manager for use in the today extension
 */
+(void)syncSharedDefaults {
    [PreferencesWindowController loadDefaultsPlist];
    NSUserDefaults *sharedDefaults = [DefaultsManager sharedDefaults];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    for (NSString *key in prefsPlist) {
        NSString *k = [key stringByAppendingString:@"Shared"]; //Appending shared to shared defaults because KVO will cause the observer to be called
        //syncing to shared defaults
        if([sharedDefaults objectForKey:k] != [d objectForKey:key]) {
            [sharedDefaults setObject:[d objectForKey:key] forKey:k];
        }
    }
    //saving selected tab manually
    [sharedDefaults setObject:[d objectForKey:@"selectedTabIndex"]  forKey:@"selectedTabIndexShared"];
}
#pragma mark colors
/**
 Converts a hex color string into an NSColor
 From http://stackoverflow.com/questions/8697205/convert-hex-color-code-to-nscolor

 @param inColorString hex color string
 @return NSColor made from hex color string
 */
+ (NSColor*)colorWithHexColorString:(NSString*)inColorString {
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString) {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    
    result = [NSColor
              colorWithCalibratedRed:(CGFloat)redByte / 0xff
              green:(CGFloat)greenByte / 0xff
              blue:(CGFloat)blueByte / 0xff
              alpha:1.0];
    return result;
}
/**
 Action taken whenever any of thethe color wells are changed

 @param sender default sender from IBAction
 */
- (IBAction)changeColor:(id)sender {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([sender isEqualTo:self.uppercaseTextColor]) {
           [d setObject:[self.uppercaseTextColor.color hexadecimalValueOfAnNSColor] forKey:@"upperTextColor"];
    } else if ([sender isEqualTo:self.lowercaseTextColor]) {
        [d setObject:[self.lowercaseTextColor.color hexadecimalValueOfAnNSColor] forKey:@"lowerTextColor"];
    } else if ([sender isEqualTo:self.numbersColor]) {
        [d setObject:[self.numbersColor.color hexadecimalValueOfAnNSColor] forKey:@"numberTextColor"];
    } else if ([sender isEqualTo:self.symbolsColor]) {
        [d setObject:[self.symbolsColor.color hexadecimalValueOfAnNSColor] forKey:@"symbolTextColor"];
    } else if ([sender isEqualTo: self.colorPasswordText]){
        [d setBool:(BOOL)self.colorPasswordText.state forKey:@"colorPasswordText"];
    }
}
#pragma mark auto clear clipboard
/**
 Clipboard erase time slider action

 @param sender default sender
 */
- (IBAction)changeClearTime:(id)sender {
    //changes the label for the clipboard erase time
    [self.clearTimeLabel setIntValue:(int)[self.clearTime integerValue]];

}
/**
 Quits or restarts the application depending on the checkboxes for the menu bar state

 @param sender default sender
 */
- (IBAction)quitOrRestartApplication:(id)sender {
    if ([self.quitButton.title isEqualToString:@"Restart"]) {
        //Restart the app if any of the menu checkboxes were changed
        NSURL *u = [[NSURL alloc] initFileURLWithPath:NSBundle.mainBundle.resourcePath];
        NSString *path = [[u URLByDeletingLastPathComponent] URLByDeletingLastPathComponent].absoluteString;
        
        NSTask *t = [[NSTask alloc] init];
        t.launchPath = @"/usr/bin/open";
        t.arguments = @[path];
        [t launch];
        exit(0);
    }
    //Quit the app if the checkbox state does not require a restart
    [[NSApplication sharedApplication] terminate:nil];
}

/**
 Called whenever the checkboxes controlling the menu bar state are called

 @param sender default sender
 */
- (IBAction)menuCheckBoxesChanged:(NSButton*)sender {
    int isMenuApp = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"isMenuApp"];
    int hideDockIcon = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"hideDockIcon"];
    NSLog(@"MENU: %d,%d DOCK %d,%d",self.initialMenuState,isMenuApp,self.initialDockState,hideDockIcon);
    [self.quitButton setTitle:@"Quit"];
    
    //Setting the initial states if they were unset
    if (self.initialMenuState == 2 && self.initialDockState == 2) {
        self.initialDockState = isMenuApp;
        self.initialMenuState = hideDockIcon;
        NSLog(@"%@",sender.title);
        //since the values get changed when they are clicked, flip the one that was clicked to make it the same as the initial state
        if ([sender.title isEqualToString:@"Hide Dock Icon"]) {
            self.initialDockState = !hideDockIcon;
        } else {
            self.initialMenuState = !isMenuApp;
        }
    }
    NSLog(@"MENU: %d,%d DOCK %d,%d",self.initialMenuState,isMenuApp,self.initialDockState,hideDockIcon);
    //Set the app to restart depending on the checkbox states as such
    //if the menu status has changed, if it is a menuApp and the dock state changes
    if ((isMenuApp ^ self.initialMenuState) || (isMenuApp && (hideDockIcon ^ self.initialDockState))) {
        [self.quitButton setTitle:@"Restart"];
    }
}
#pragma mark - Custom shortcut
/**
 Sets the global shortcut callback
 */
- (void)resetShortcutRegistration {
    //The global shortcut was set, so setup the callback
    if ([[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyShortcutEnabled]) {
        NSLog(@"SKey %@",@"RESET SHORTCUT");
        [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:MASPreferenceKeyShortcut
                     toAction:^{
                         //Loads the app delegate and runs generateAndCopy when the shortcut us pressed
                         NSLog(@"SHORTCUT PRESSED");
                         AppDelegate *d = [NSApplication sharedApplication].delegate;
                         [d.masterViewController generateAndCopy];
                     }];
    }
    //the shortcut was turned off, so unbind it
    else {
        [[MASShortcutBinder sharedBinder] unbind:MASPreferenceKeyShortcut];
    }
}

/**
 Adds to login items based upon preference state

 @param sender default sender
 */
- (IBAction)changeLoginItem:(NSButton *)sender {
    //get the login item status from preferences and change the checkbox state

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    if(sender == nil) {
        //called from showWindow
        //checks to see if the item has been manually removed or added from login items and changes the state to match
        if ([self.loginItem isLoginItem] && self.addToLoginItems.state == NSControlStateValueOff) {
            self.addToLoginItems.state = NSControlStateValueOn;
            [d setBool:YES forKey:@"addToLoginItems"];
        } else if (![self.loginItem isLoginItem] && (self.addToLoginItems.state == NSControlStateValueOn)) {
            self.addToLoginItems.state = NSControlStateValueOff;
            [d setBool:NO forKey:@"addToLoginItems"];
        }
    }
    //turns on or off depending on checkbox state
    if ([d boolForKey:@"addToLoginItems"]) {
        //login item on
        if(![self.loginItem isLoginItem]) {
            [self.loginItem addLoginItem];
        }
    } else {
        if([self.loginItem isLoginItem]) {
            [self.loginItem removeLoginItem];
        }
    }
}
@end
