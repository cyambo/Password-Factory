//
//  PreferencesViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "PreferencesViewController.h"
#import "NSColor+NSColorHexadecimalValue.h"
#import "NSString+ColorWithHexColorString.h"
#import "AppDelegate.h"
#import "DefaultsManager.h"
#import "constants.h"
#import <ServiceManagement/ServiceManagement.h>
#import "Utilities.h"
#import "PasswordStorage.h"
NSString *const MASPreferenceKeyShortcut = @"MASPGShortcut";
NSString *const MASPreferenceKeyShortcutEnabled = @"MASPGShortcutEnabled";

@implementation PreferencesViewController

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setObservers];
    
    //setting the initial checkbox states for the menu and dock checkboxes to an unset state
    self.initialMenuState = 2;
    self.initialDockState = 2;

    return self;
}
- (void)awakeFromNib {

    //setup shortcut handler
    [self.shortcutView bind:@"enabled" toObject:[DefaultsManager standardDefaults] withKeyPath:MASPreferenceKeyShortcutEnabled options:nil];
    
    // Shortcut view will follow and modify user preferences automatically
    self.shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;
}

- (void)viewWillAppear {
    [self updatePrefsUI];
    [self resetShortcutRegistration];
    [self changeLoginItem:nil];
    //setting up notification sound
    NSString *sound = [[DefaultsManager get] stringForKey:@"notificationSound"];
    [self.soundSelector selectItemWithTitle:sound];
}

#pragma mark observers
/**
 Sets the observers for the class
 */
-(void)setObservers {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    //sets the observer for the global shortcut key
    [d addObserver:self
        forKeyPath:MASPreferenceKeyShortcutEnabled
           options:NSKeyValueObservingOptionNew
           context:NULL];

}
-(void)unsetObservers {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    //remove observer
    [d removeObserver:self forKeyPath:MASPreferenceKeyShortcutEnabled];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //observing when the global shortcut is enabled
    if ([keyPath isEqualToString:MASPreferenceKeyShortcutEnabled]) {
        [self resetShortcutRegistration];
    }
}
-(void)dealloc {
    [self unsetObservers];
}
#pragma mark prefs
/**
 Setup for the prefs window to fill in the set values
 */
-(void)updatePrefsUI {
    DefaultsManager *d = [DefaultsManager get];
    //Loading up the erase clipboard timer
    [self.clearTimeLabel setIntValue:(int)[d integerForKey:@"clearClipboardTime"]];
    
    //setting the color wells
    [self.uppercaseTextColor setColor: [[d stringForKey:@"upperTextColor"] colorWithHexColorString]];
    [self.lowercaseTextColor setColor: [[d stringForKey:@"lowerTextColor"] colorWithHexColorString]];
    [self.symbolsColor setColor: [[d stringForKey:@"symbolTextColor"] colorWithHexColorString]];
    [self.numbersColor setColor: [[d stringForKey:@"numberTextColor"] colorWithHexColorString]];
    [self.defaultColor setColor: [[d stringForKey:@"defaultTextColor"] colorWithHexColorString]];
}


#pragma mark colors

/**
 Action taken whenever any of thethe color wells are changed

 @param sender default sender from IBAction
 */
- (IBAction)changeColor:(id)sender {
    DefaultsManager *d = [DefaultsManager get];
    if ([sender isEqualTo:self.uppercaseTextColor]) {
           [d setObject:[self.uppercaseTextColor.color hexadecimalValueOfAnNSColor] forKey:@"upperTextColor"];
    } else if ([sender isEqualTo:self.lowercaseTextColor]) {
        [d setObject:[self.lowercaseTextColor.color hexadecimalValueOfAnNSColor] forKey:@"lowerTextColor"];
    } else if ([sender isEqualTo:self.numbersColor]) {
        [d setObject:[self.numbersColor.color hexadecimalValueOfAnNSColor] forKey:@"numberTextColor"];
    } else if ([sender isEqualTo:self.symbolsColor]) {
        [d setObject:[self.symbolsColor.color hexadecimalValueOfAnNSColor] forKey:@"symbolTextColor"];
    } else if ([sender isEqualTo:self.defaultColor]) {
        [d setObject:[self.defaultColor.color hexadecimalValueOfAnNSColor] forKey:@"defaultTextColor"];
    } else if ([sender isEqualTo: self.colorPasswordText]){
        [d setBool:(BOOL)self.colorPasswordText.state forKey:@"colorPasswordText"];
    }
}

/**
 Disables or enables password storage

 @param sender default sender
 */
- (IBAction)changeStoredPassword:(NSButton *)sender {
    AppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
    DefaultsManager *d = [DefaultsManager get];
    if(sender.state == NSControlStateValueOn) {
        [appDelegate.masterViewController enableStoredPasswords];
        [appDelegate.alertWindowController displayAlertWithBlock:StoredPasswordOnWarning defaultsKey:@"hideStoredPasswordOnWarning" window:self.view.window closeBlock:^(BOOL cancelled) {
            if(cancelled) {
                [d setBool:NO forKey:@"storePasswords"];
            } else {
                [appDelegate.masterViewController enableStoredPasswords];
            }
            [Utilities setRemoteStore];
        }];

    } else {
        [appDelegate.alertWindowController displayAlertWithBlock:StoredPasswordOffWarning defaultsKey:@"hideStoredPasswordOffWarning" window:self.view.window closeBlock:^(BOOL cancelled) {
            if(cancelled) {
                [d setBool:YES forKey:@"storePasswords"];
            } else {
                [appDelegate.masterViewController disableStoredPasswords];
            }
            [Utilities setRemoteStore];
        }];
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
        [self restartApplication];
    }
    //Quit the app if the checkbox state does not require a restart
    [[NSApplication sharedApplication] terminate:nil];
}

/**
 Restarts the application
 */
-(void)restartApplication {
    NSURL *u = [[NSURL alloc] initFileURLWithPath:NSBundle.mainBundle.resourcePath];
    NSString *path = [[u URLByDeletingLastPathComponent] URLByDeletingLastPathComponent].absoluteString;
    
    NSTask *t = [[NSTask alloc] init];
    t.launchPath = @"/usr/bin/open";
    t.arguments = @[path];
    [t launch];
    exit(0);
}
/**
 Called whenever the checkboxes controlling the menu bar state are called

 @param sender default sender
 */
- (IBAction)menuCheckBoxesChanged:(NSButton*)sender {
    int isMenuApp = (int)[[DefaultsManager get] integerForKey:@"isMenuApp"];
    int hideDockIcon = (int)[[DefaultsManager get] integerForKey:@"hideDockIcon"];

    [self.quitButton setTitle:@"Quit"];
    
    //Setting the initial states if they were unset
    if (self.initialMenuState == 2 && self.initialDockState == 2) {
        self.initialDockState = isMenuApp;
        self.initialMenuState = hideDockIcon;
        //since the values get changed when they are clicked, flip the one that was clicked to make it the same as the initial state
        if ([sender.title isEqualToString:@"Hide Dock Icon"]) {
            self.initialDockState = !hideDockIcon;
        } else {
            self.initialMenuState = !isMenuApp;
        }
    }

    //Set the app to restart depending on the checkbox states as such
    //if the menu status has changed, if it is a menuApp and the dock state changes
    if ((isMenuApp ^ self.initialMenuState) || (isMenuApp && (hideDockIcon ^ self.initialDockState))) {
        AppDelegate *delegate = [NSApplication sharedApplication].delegate;
        [delegate.alertWindowController displayAlert:MenuRestartMessage defaultsKey:@"hideMenuRestartWarning" window:self.view.window];
        [self.quitButton setTitle:@"Restart"];
    }
}
#pragma mark - Custom shortcut
/**
 Sets the global shortcut callback
 */
- (void)resetShortcutRegistration {
    //The global shortcut was set, so setup the callback
    if ([[DefaultsManager standardDefaults] boolForKey:MASPreferenceKeyShortcutEnabled]) {

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
        [[MASShortcutBinder sharedBinder] breakBindingWithDefaultsKey:MASPreferenceKeyShortcut];
    }
}


/**
 Shows help window

 @param sender default sender
 */
- (IBAction)showHelp:(id)sender {
    [[NSApplication sharedApplication] showHelp:nil];
}

/**
 Adds to login items based upon preference state

 @param sender default sender
 */
- (IBAction)changeLoginItem:(NSButton *)sender {
    //get the login item status from preferences and change the checkbox state

    DefaultsManager *d = [DefaultsManager get];
    BOOL isLoginItem = [self isLoginItem];
    if(sender == nil) {
        //called from viewWillAppear
        //checks to see if the item has been manually removed or added from login items and changes the state to match
        if (isLoginItem && self.addToLoginItems.state == NSControlStateValueOff) {
            self.addToLoginItems.state = NSControlStateValueOn;
            [d setBool:YES forKey:@"addToLoginItems"];
        } else if (!isLoginItem && (self.addToLoginItems.state == NSControlStateValueOn)) {
            self.addToLoginItems.state = NSControlStateValueOff;
            [d setBool:NO forKey:@"addToLoginItems"];
        }
    } else {

        if (![self isInApplicationsDirectory]) {
            //check to see if app is in Applications because login items only work from there
            self.addToLoginItems.state = NSControlStateValueOff;
            [d setBool:NO forKey:@"addToLoginItems"];
            AppDelegate *delegate = [NSApplication sharedApplication].delegate;
            [delegate.alertWindowController displayAlert:StartAtLoginNotInApplicationsWarning defaultsKey:@"hideStartAtLoginNotInApplicationsWarning" window:self.view.window];
            return;
        }
    }
    //only do this if we are in Applications
    if ([self isInApplicationsDirectory]) {
        //turns on or off depending on checkbox state
        if ([d boolForKey:@"addToLoginItems"]) {
            //login item on
            if(!isLoginItem) {
                if (![self setLoginItem:YES]) {
                    NSLog(@"SET LOGIN FAILED");
                } else {
                    NSLog(@"SET LOGIN succeeded!");
                }
            }
        } else {
            if(isLoginItem) {
                if (![self setLoginItem:NO]) {
                    NSLog(@"UNSET LOGIN FAILED");
                } else {
                    NSLog(@"UNSET LOGIN succeeded!");
                }
            }
        }
    }
}

/**
 Sets login item on or off

 @param set turn on or off
 @return Success
 */
-(BOOL)setLoginItem:(BOOL)set {
    if(set) {
        NSURL *url = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Contents/Library/Password Factory Helper.app" isDirectory:NO];
        // Registering helper app
        if (LSRegisterURL((__bridge CFURLRef)url, true) != noErr) {
            NSLog(@"LSRegisterURL failed!");
        } else {
            NSLog(@"LSRegisterURL succeeded!");
        }
        return SMLoginItemSetEnabled((__bridge CFStringRef)HelperIdentifier, YES);

    } else {
        return SMLoginItemSetEnabled((__bridge CFStringRef)HelperIdentifier, NO);
    }
}
/**
 Checks to see if the app is in the Applications directory

 @return YES if it is in /Applications
 */
-(BOOL)isInApplicationsDirectory {
    NSArray *applicationPath = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] pathComponents];
    return [applicationPath[1] isEqualToString:@"Applications"];
}

/**
 Checks to see if the app is already a login item

 @return YES if it is a login item
 */
-(BOOL) isLoginItem {
    // the easy and sane method (SMJobCopyDictionary) can pose problems when sandboxed. -_-
    CFArrayRef cfJobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    NSArray* jobDicts = CFBridgingRelease(cfJobDicts);
    
    if (jobDicts && [jobDicts count] > 0) {
        for (NSDictionary* job in jobDicts) {
            if ([HelperIdentifier isEqualToString:[job objectForKey:@"Label"]]) {
                return [[job objectForKey:@"OnDemand"] boolValue];
            }
        }
    }
    return NO;
}
/**
 Called when sound is changed

 @param sender default sender
 */
- (IBAction)selectSound:(NSPopUpButton *)sender {
    NSString *soundName = [sender selectedItem].title;
    [[DefaultsManager get] setObject:soundName forKey:@"notificationSound"]; //store it in defaults
    [[NSSound soundNamed:soundName] play]; //play the sound
}


/**
 Resets the defaults and stored password to defaultes

 @param sender default sender
 */
- (IBAction)resetToDefaults:(NSButton *)sender {
    AppDelegate *d = [NSApplication sharedApplication].delegate;
    [d.alertWindowController displayAlertWithBlock:ResetToDefaultsWarning defaultsKey:nil window:self.view.window closeBlock:^(BOOL cancelled) {
        if(!cancelled) {
            //restore defaults
            [DefaultsManager restoreUserDefaults];
            //delete everything in storage
            [[PasswordStorage get] deleteAllEntities];
            //turn off login item
            if([self isLoginItem]) {
                [self setLoginItem:NO];
            }
            //turn off shortcut
            [self resetShortcutRegistration];
            //restart
            [self restartApplication];
        }
    }];
}

/**
 Resets all dialogs so that they will be shown

 @param sender default sender
 */
- (IBAction)resetAllDialogs:(NSButton *)sender {
    AppDelegate *d = [NSApplication sharedApplication].delegate;
    [d.alertWindowController displayAlertWithBlock:ResetAllDialogsWarning defaultsKey:nil  window:self.view.window closeBlock:^(BOOL cancelled) {
        if(!cancelled) {
            [[DefaultsManager get] resetDialogs];
        }
    }];
}
- (IBAction)changeRemoteStorage:(NSButton *)sender {
    NSString *message;
    if (sender.state == NSControlStateValueOn) {
        message = enableRemoteStoreWarning;
    } else {
        message = disableRemoteStoreWarning;
    }
    AppDelegate *d = [NSApplication sharedApplication].delegate;
    [d.alertWindowController displayAlertWithBlock:message defaultsKey:nil window:self.view.window closeBlock:^(BOOL cancelled) {
        if(!cancelled) {
            [Utilities setRemoteStore];
        } else {
            if (sender.state == NSControlStateValueOn) {
                sender.state = NSControlStateValueOff;
            } else {
                sender.state = NSControlStateValueOn;
            }
        }
    }];
    
}
    
- (IBAction)eraseRemoteStorage:(NSButton *)sender {
    AppDelegate *d = [NSApplication sharedApplication].delegate;
    [d.alertWindowController displayAlertWithBlock:eraseRemoteStoreWarning defaultsKey:nil window:self.view.window closeBlock:^(BOOL cancelled) {
        if(!cancelled) {
            [DefaultsManager removeRemoteDefaults];
            [[PasswordStorage get] deleteAllRemoteObjects];
        }
    }];

}
    @end
