//
//  PreferencesViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

@import Cocoa;
#import <MASShortcut/Shortcut.h>

@interface PreferencesViewController : NSViewController <NSTextFieldDelegate>

@property (weak) IBOutlet NSButton *colorPasswordText;
@property (weak) IBOutlet NSColorWell *uppercaseTextColor;
@property (weak) IBOutlet NSColorWell *lowercaseTextColor;
@property (weak) IBOutlet NSColorWell *numbersColor;
@property (weak) IBOutlet NSColorWell *symbolsColor;
@property (weak) IBOutlet NSColorWell *defaultColor;
@property (weak) IBOutlet NSColorWell *extendedColor;

- (IBAction)changeColor:(id)sender;

@property (weak) IBOutlet NSButton *storedPasswordCheckbox;

@property (weak) IBOutlet NSButton *automaticallyClearClipboard;
@property (weak) IBOutlet NSSlider *clearTime;
@property (weak) IBOutlet NSTextField *clearTimeLabel;
- (IBAction)changeClearTime:(id)sender;

@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;
@property (weak) IBOutlet NSButton *displayNotification;
@property (weak) IBOutlet NSButton *playNotificationSound;
@property (weak) IBOutlet NSButton *enableGlobalHotkey;
- (IBAction)selectSound:(NSPopUpButton *)sender;
@property (weak) IBOutlet NSPopUpButton *soundSelector;
- (void)resetShortcutRegistration;

- (IBAction)quitOrRestartApplication:(id)sender;
@property (nonatomic, assign) int initialMenuState;
@property (nonatomic, assign) int initialDockState;
@property (weak) IBOutlet NSButton *quitButton;
- (IBAction)menuCheckBoxesChanged:(id)sender;

- (IBAction)showHelp:(id)sender;

@property (weak) IBOutlet NSButton *addToLoginItems;
- (IBAction)changeLoginItem:(NSButton *)sender;

@property (weak) IBOutlet NSButton *iCloudSync;
    
- (IBAction)resetToDefaults:(NSButton *)sender;
- (IBAction)resetAllDialogs:(NSButton *)sender;
- (IBAction)eraseRemoteStorage:(NSButton *)sender;

@end
