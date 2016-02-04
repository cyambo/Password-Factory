//
//  PreferencesWindowController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2014 c13. All rights reserved.
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

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        

    }
    return self;
}
- (void)awakeFromNib {

    [PreferencesWindowController loadPreferencesFromPlist];
    [self updatePrefsUI];
    [self setObservers];
    
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
    
}

-(void)showWindow:(id)sender {
    // Activate the global keyboard shortcut if it was enabled last time
    //moved to showWindow instead of awakeFromNib so that it will load everytime the window pops up
    [self resetShortcutRegistration];
    [super showWindow:sender];
}

#pragma mark observers
-(void)setObservers {

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

        [d addObserver:self
            forKeyPath:MASPreferenceKeyShortcutEnabled
               options:NSKeyValueObservingOptionNew
               context:NULL];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:MASPreferenceKeyShortcutEnabled]) {
        [self resetShortcutRegistration];
    }
}
#pragma mark prefs
-(void)updatePrefsUI {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

    [self.clearTimeLabel setIntValue:(int)[d integerForKey:@"clearClipboardTime"]];

    [self.uppercaseTextColor setColor: [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"upperTextColor"]]];
    [self.lowercaseTextColor setColor: [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"lowerTextColor"]]];
    [self.symbolsColor setColor: [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"symbolTextColor"]]];
    [self.numbersColor setColor: [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"numberTextColor"]]];
    

    
}


+(void)loadPreferencesFromPlist {
    if (!loadedPrefs) {
        [PreferencesWindowController getPrefsFromPlist];
        loadedPrefs = YES;
    }

}
+(void)loadDefaultsPlist {
    if (prefsPlist == nil) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
        prefsPlist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        NSLog(@"LOADED PREFS");
    }
}
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
// From http://stackoverflow.com/questions/8697205/convert-hex-color-code-to-nscolor
+ (NSColor*)colorWithHexColorString:(NSString*)inColorString
{
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
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
- (IBAction)changeClearTime:(id)sender {

    [self.clearTimeLabel setIntValue:(int)[self.clearTime integerValue]];

}

- (IBAction)quitApplication:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}


#pragma mark - Custom shortcut
- (void)resetShortcutRegistration
{
  
    if ([[NSUserDefaults standardUserDefaults] boolForKey:MASPreferenceKeyShortcutEnabled]) {
        NSLog(@"SKey %@",@"RESET SHORTCUT");
        [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:MASPreferenceKeyShortcut
                     toAction:^{
                         NSLog(@"SHORTCUT PRESSED");
                         AppDelegate *d = [NSApplication sharedApplication].delegate;
                         [d.masterViewController generateAndCopy];
                     }];
    }
    else {
        [[MASShortcutBinder sharedBinder] unbind:MASPreferenceKeyShortcut];
    }

}

@end
