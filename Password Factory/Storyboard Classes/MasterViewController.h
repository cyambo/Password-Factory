//
//  MasterViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
#import "PreferencesViewController.h"
#import "ZoomViewController.h"
#import "StrengthMeter.h"
#import "PasswordController.h"

@interface MasterViewController : NSViewController 
@property (nonatomic, strong) PasswordController *password;
@property (weak) IBOutlet NSTextField *passwordField;
@property (weak) IBOutlet NSTextField *displayedPasswordLength;

@property (weak) IBOutlet StrengthMeter *passwordStrengthLevel;

@property (weak) IBOutlet NSButton *generateButton;
@property (weak) IBOutlet NSButton *pasteboardButton;
- (IBAction)copyToClipboard:(id)sender;

- (void)setPasswordStrength;
- (void)generatePassword;

- (void)clearClipboard;
- (void)updatePasteboard:(NSString *)val;

@property (nonatomic,assign) BOOL colorPasswordText;
- (void)generateAndCopy;

@property (nonatomic, weak) NSWindowController *prefsWindowController;
@property (nonatomic, weak) NSWindowController *zoomWindowController;

- (IBAction)loadPreferencesWindow:(id)sender;
@property (weak) IBOutlet NSButton *loadPreferencesButton;

- (IBAction)generateAction:(id)sender;

@property (weak) IBOutlet NSButton *crackTimeButton;
- (IBAction)toggleCrackTimeDisplay:(id)sender;
- (IBAction)zoomPassword:(id)sender;

@property (weak) IBOutlet NSView *passwordView;
@property (weak) IBOutlet NSTableView *passwordTypesTable;
- (void)selectPaswordType:(PFPasswordType)type;
- (PFPasswordType)getSelectedPasswordType;
-(void)enableStoredPasswords;
-(void)disableStoredPasswords;
@end
