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


@property (weak) IBOutlet NSSlider *passwordLengthSlider;



@property (weak) IBOutlet NSStepper *passwordLengthStepper;
@property (weak) IBOutlet NSTextField *passwordLengthText;


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
- (int)getPronounceableSeparatorType;

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


@property (weak) IBOutlet NSMatrix *passphraseSeparatorRadio;
@property (weak) IBOutlet NSMatrix *passphraseCaseRadio;

- (IBAction)pressPassphraseSeparatorRadio:(id)sender;
- (IBAction)pressPassphraseCaseRadio:(id)sender;


@end
