//
//  MasterViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PasswordFactory.h"
#import "PreferencesWindowController.h"
#import "StrengthMeter.h"
@interface MasterViewController : NSViewController
@property (weak) IBOutlet NSTextField *passwordField;

@property (weak) IBOutlet NSButton *useSymbols;
@property (weak) IBOutlet NSButton *mixedCase;
@property (weak) IBOutlet NSButton *avoidAmbiguous;
@property (weak) IBOutlet NSSlider *passwordLengthSliderPrononunceable;
@property (weak) IBOutlet NSTextField *passwordLengthLabelPronounceable;
@property (weak) IBOutlet NSSlider *passwordLengthSliderRandom;
@property (weak) IBOutlet NSTextField *passwordLengthLabelRandom;
@property (weak) IBOutlet StrengthMeter *passwordStrengthLevel;

@property (weak) IBOutlet NSTabView *passwordTypeTab;

@property (weak) IBOutlet NSTextField *patternText;
@property (weak) IBOutlet NSMatrix *pronounceableSeparatorRadio;

@property (nonatomic, strong) PasswordFactory *pg;

@property (weak) IBOutlet NSButton *generateButton;
@property (weak) IBOutlet NSButton *pasteboardButton;
- (IBAction)copyToPasteboard:(id)sender;

- (IBAction)changeLength:(id)sender;
- (IBAction)pressPrononunceableRadio:(id)sender;
- (NSString *)getPronounceableRadioSelected;

- (void)setPasswordStrength;
@property (nonatomic, strong) NSString *passwordValue;
- (void)generatePassword;

- (void)clearClipboard;
- (void)updatePasteboard:(NSString *)val;

@property (nonatomic,assign) BOOL colorPasswordText;
- (void)generateAndCopy;

@property (nonatomic, weak) PreferencesWindowController *prefsWindow;

-(NSImage *)getMenuImage:(BOOL)isMenuClicked;

@property (weak) IBOutlet NSButton *loadPreferencesButton;

@end
