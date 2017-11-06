//
//  PasswordTypesViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
@interface PasswordTypesViewController : NSViewController
@property (weak) IBOutlet NSButton *useSymbols;
@property (weak) IBOutlet NSButton *mixedCase;
@property (weak) IBOutlet NSButton *avoidAmbiguous;

@property (weak) IBOutlet NSSlider *passwordLengthSlider;

@property (weak) IBOutlet NSTextField *passwordLengthText;

@property (weak) IBOutlet NSTextField *patternText;
@property (weak) IBOutlet NSMatrix *pronounceableSeparatorRadio;

- (IBAction)changeLength:(id)sender;
- (IBAction)pressPrononunceableRadio:(id)sender;
- (PFSeparatorType)getPronounceableSeparatorType;
@property (weak) IBOutlet NSMatrix *passphraseSeparatorRadio;
@property (weak) IBOutlet NSMatrix *passphraseCaseRadio;

- (IBAction)pressPassphraseSeparatorRadio:(id)sender;
- (IBAction)pressPassphraseCaseRadio:(id)sender;
@end
