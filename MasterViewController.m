//
//  MasterViewController.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "MasterViewController.h"
#import "BBPasswordStrength.h"
#import "PasswordGenerator.h"

@interface MasterViewController () <NSTabViewDelegate, NSTextFieldDelegate>

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

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pg = [[PasswordGenerator alloc] init];
    }
    return self;
}
- (void)awakeFromNib {
    [self getPasswordLength];
    [[self passwordTypeTab] setDelegate:self];
    [[self patternText] setDelegate:self];
    
}
- (IBAction)copyToPasteboard:(id)sender {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *toPasteboard = @[self.passwordField.stringValue];
    BOOL ok = [pasteboard writeObjects:toPasteboard];
    if (!ok) { NSLog(@"Write to pasteboard failed");}
    
}
- (void)controlTextDidChange:(NSNotification *)obj {
    [self generatePassword];
}
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [self generatePassword];
}
- (IBAction)pressPrononunceableRadio:(id)sender {
    [self generatePassword];
}

- (IBAction)changeLength:(id)sender {
    [self getPasswordLength];
}
- (IBAction)generateAction:(id)sender {
    [self generatePassword];
}

- (void)getButtonStates {
    self.pg.useSymbols = [self.useSymbols state];
    self.pg.avoidAmbiguous = [self.avoidAmbiguous state];
    self.pg.mixedCase = [self.mixedCase state];
}
- (void)getPasswordLength{
    NSInteger atTab = [self.passwordTypeTab.selectedTabViewItem.identifier intValue];
    if (atTab == 0) {
        self.pg.passwordLength = [self.passwordLengthSliderRandom integerValue];
        [self.passwordLengthSliderPrononunceable setIntegerValue:self.pg.passwordLength];
    } else {
        self.pg.passwordLength = [self.passwordLengthSliderPrononunceable integerValue];
        [self.passwordLengthSliderRandom setIntegerValue:self.pg.passwordLength];
    }
    [self.passwordLengthLabelRandom setStringValue:[NSString stringWithFormat:@"%i",(int)self.pg.passwordLength]];
    [self.passwordLengthLabelPronounceable setStringValue:[NSString stringWithFormat:@"%i",(int)self.pg.passwordLength]];
    [self generatePassword];
}

- (void)generatePassword {
    NSInteger atTab = [self.passwordTypeTab.selectedTabViewItem.identifier intValue];
    NSString *passwordValue;
    [self getButtonStates];
    switch (atTab) {
        case 0: //random
            passwordValue = [self.pg generateRandom];
            break;
        case 1: //pattern
            passwordValue = [self.pg generatePattern:self.patternText.stringValue];
            break;
        case 2: //pronounceable
            passwordValue = [self.pg generatePronounceable:[self getPronounceableRadioSelected]];
            break;
    }
    [self.passwordField setStringValue: passwordValue];
    [self setPasswordStrength:passwordValue];
    
    
}
- (NSString *)getPronounceableRadioSelected {
    NSButtonCell *selected = [[self pronounceableSeparatorRadio] selectedCell];
    return selected.title;
}
- (void)setPasswordStrength:(NSString *)password {
    BBPasswordStrength *strength = [[BBPasswordStrength alloc] initWithPassword:password];
    //playing around with numbers to make a good scale
    double ct = log10(strength.crackTime/100)*10;
    if (ct > 100) {ct = 100;}
    [self.passwordStrengthLevel setFloatValue:ct];
}





@end
