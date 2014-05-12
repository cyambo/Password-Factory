//
//  MasterViewController.h
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PasswordGenerator.h"
@interface MasterViewController : NSViewController
@property (weak) IBOutlet NSTextField *passwordField;

@property (weak) IBOutlet NSButton *useSymbols;
@property (weak) IBOutlet NSButton *mixedCase;
@property (weak) IBOutlet NSButton *avoidAmbiguous;
@property (weak) IBOutlet NSSlider *passwordLengthSliderPrononunceable;
@property (weak) IBOutlet NSTextField *passwordLengthLabelPronounceable;
@property (weak) IBOutlet NSSlider *passwordLengthSliderRandom;
@property (weak) IBOutlet NSTextField *passwordLengthLabelRandom;
@property (weak) IBOutlet NSLevelIndicator *passwordStrengthLevel;
@property (weak) IBOutlet NSTabView *passwordTypeTab;

@property (weak) IBOutlet NSTextField *patternText;
@property (weak) IBOutlet NSMatrix *pronounceableSeparatorRadio;

@property (nonatomic, strong) PasswordGenerator *pg;


- (IBAction)changeLength:(id)sender;
- (IBAction)pressPrononunceableRadio:(id)sender;
- (NSString *)getPronounceableRadioSelected;
@end
