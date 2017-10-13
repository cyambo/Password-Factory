//
//  PreferencesWindowController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MASShortcut/Shortcut.h>



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

- (IBAction)quitOrRestartApplication:(id)sender;

@property (nonatomic, assign) int initialMenuState;
@property (nonatomic, assign) int initialDockState;
@property (weak) IBOutlet NSButton *quitButton;
- (IBAction)menuCheckBoxesChanged:(id)sender;

- (void)resetShortcutRegistration;
@end
