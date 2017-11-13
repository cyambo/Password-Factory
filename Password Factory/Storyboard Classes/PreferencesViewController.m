//
//  PreferencesViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "PreferencesViewController.h"
#import "NSColor+NSColorHexadecimalValue.h"
#import "AppDelegate.h"
#import "DefaultsManager.h"
#import "constants.h"
NSString *const MASPreferenceKeyShortcut = @"MASPGShortcut";
NSString *const MASPreferenceKeyShortcutEnabled = @"MASPGShortcutEnabled";

@implementation PreferencesViewController



-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setObservers];
    return self;
}
- (void)awakeFromNib {

    
    [self updatePrefsUI];
    
    
    //setup shortcut handler
    [self.shortcutView bind:@"enabled" toObject:[DefaultsManager standardDefaults] withKeyPath:MASPreferenceKeyShortcutEnabled options:nil];
    
    // Shortcut view will follow and modify user preferences automatically
    self.shortcutView.associatedUserDefaultsKey = MASPreferenceKeyShortcut;
    
    //setting the initial checkbox states for the menu and dock checkboxes to an unset state
    self.initialMenuState = 2;
    self.initialDockState = 2;
    
    //initting login item
    self.loginController = [[StartAtLoginController alloc] initWithIdentifier:HelperIdentifier];
    
    //setting up notification sound
    NSString *sound = [[DefaultsManager standardDefaults] stringForKey:@"notificationSound"];
    [self.soundSelector selectItemWithTitle:sound];
}

- (void)viewWillAppear {
    [self resetShortcutRegistration];
    [self changeLoginItem:nil];
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
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    //Loading up the erase clipboard timer
    [self.clearTimeLabel setIntValue:(int)[d integerForKey:@"clearClipboardTime"]];
    
    //setting the color wells
    [self.uppercaseTextColor setColor: [PreferencesViewController colorWithHexColorString:[d objectForKey:@"upperTextColor"]]];
    [self.lowercaseTextColor setColor: [PreferencesViewController colorWithHexColorString:[d objectForKey:@"lowerTextColor"]]];
    [self.symbolsColor setColor: [PreferencesViewController colorWithHexColorString:[d objectForKey:@"symbolTextColor"]]];
    [self.numbersColor setColor: [PreferencesViewController colorWithHexColorString:[d objectForKey:@"numberTextColor"]]];
    [self.defaultColor setColor: [PreferencesViewController colorWithHexColorString:[d objectForKey:@"defaultTextColor"]]];
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
    NSUserDefaults *d = [DefaultsManager standardDefaults];
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
    int isMenuApp = (int)[[DefaultsManager standardDefaults] integerForKey:@"isMenuApp"];
    int hideDockIcon = (int)[[DefaultsManager standardDefaults] integerForKey:@"hideDockIcon"];

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

    NSUserDefaults *d = [DefaultsManager standardDefaults];
    BOOL isLoginItem = [self.loginController startAtLogin];
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
        NSArray *applicationPath = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] pathComponents];
        if (![applicationPath[1] isEqualToString:@"Applications"]) {
            //check to see if app is in Applications because login items only work from there
            self.addToLoginItems.state = NSControlStateValueOff;
            [d setBool:NO forKey:@"addToLoginItems"];
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Error"];
            [alert setInformativeText:@"Password Factory must be installed in Applications to add to Login Items"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            return;
        }
    }
    //turns on or off depending on checkbox state
    if ([d boolForKey:@"addToLoginItems"]) {
        //login item on
        if(!isLoginItem) {
            self.loginController.startAtLogin = YES;
        }
    } else {
        if(isLoginItem) {
            self.loginController.enabled = NO;
        }
    }
}

/**
 Called when sound is changed

 @param sender default sender
 */
- (IBAction)selectSound:(NSPopUpButton *)sender {
    NSString *soundName = [sender selectedItem].title;
    [[DefaultsManager standardDefaults] setObject:soundName forKey:@"notificationSound"];
    [[NSSound soundNamed:soundName] play];
}
@end
