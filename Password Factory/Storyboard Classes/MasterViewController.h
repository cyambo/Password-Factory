//
//  MasterViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PasswordFactory.h"
#import "PreferencesViewController.h"
#import "StrengthMeter.h"

@interface MasterViewController : NSViewController 

@property (weak) IBOutlet NSTextField *passwordField;

@property (weak) IBOutlet NSButton *useSymbols;
@property (weak) IBOutlet NSButton *mixedCase;
@property (weak) IBOutlet NSButton *avoidAmbiguous;

@property (weak) IBOutlet NSSlider *passwordLengthSlider;

@property (weak) IBOutlet NSTextField *passwordLengthText;

@property (weak) IBOutlet StrengthMeter *passwordStrengthLevel;

@property (weak) IBOutlet NSTabView *passwordTypeTab;

@property (weak) IBOutlet NSTextField *patternText;
@property (weak) IBOutlet NSMatrix *pronounceableSeparatorRadio;

@property (nonatomic, strong) PasswordFactory *pf;
@property (nonatomic, strong) NSColor *defaultCharacterColor;
@property (weak) IBOutlet NSButton *generateButton;
@property (weak) IBOutlet NSButton *pasteboardButton;
- (IBAction)copyToClipboard:(id)sender;

- (IBAction)changeLength:(id)sender;
- (IBAction)pressPrononunceableRadio:(id)sender;
- (PFSeparatorType)getPronounceableSeparatorType;

- (void)setPasswordStrength;
@property (nonatomic, strong) NSString *passwordValue;
- (void)generatePassword;

- (void)clearClipboard;
- (void)updatePasteboard:(NSString *)val;

@property (nonatomic,assign) BOOL colorPasswordText;
- (void)generateAndCopy;

@property (nonatomic, weak) NSWindowController *prefsWindowController;

@property (weak) IBOutlet NSButton *loadPreferencesButton;

@property (weak) IBOutlet NSMatrix *passphraseSeparatorRadio;
@property (weak) IBOutlet NSMatrix *passphraseCaseRadio;

- (IBAction)pressPassphraseSeparatorRadio:(id)sender;
- (IBAction)pressPassphraseCaseRadio:(id)sender;

- (IBAction)generateAction:(id)sender;
@property (weak) IBOutlet NSButton *crackTimeButton;
- (IBAction)toggleCrackTimeDisplay:(id)sender;

@property (weak) IBOutlet NSView *passwordView;
@property (weak) IBOutlet NSTableView *passwordTypeSelection;
@end
