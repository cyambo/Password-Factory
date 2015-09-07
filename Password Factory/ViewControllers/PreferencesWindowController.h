//
//  PreferencesWindowController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcutView.h"



@interface PreferencesWindowController : NSWindowController <NSTextFieldDelegate>

@property (weak) IBOutlet NSButton *colorPasswordText;
@property (weak) IBOutlet NSColorWell *uppercaseTextColor;
@property (weak) IBOutlet NSColorWell *lowercaseTextColor;
@property (weak) IBOutlet NSColorWell *numbersColor;
@property (weak) IBOutlet NSColorWell *symbolsColor;
- (IBAction)changeColor:(id)sender;

@property (weak) IBOutlet NSButton *automaticallyClearClipboard;
@property (weak) IBOutlet NSSlider *clearTime;
@property (weak) IBOutlet NSTextField *clearTimeLabel;
- (IBAction)changeClearTime:(id)sender;

+ (void)loadPreferencesFromPlist;
+ (void)getPrefsFromPlist;
+(void)syncSharedDefaults;

+ (NSColor*)colorWithHexColorString:(NSString*)inColorString;

@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (weak) IBOutlet NSButton *displayNotification;
@property (weak) IBOutlet NSButton *playNotificationSound;
@property (weak) IBOutlet NSButton *enableGlobalHotkey;

- (IBAction)quitApplication:(id)sender;


- (void)resetShortcutRegistration;
@end
