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
    NSInteger changeCount = [pasteboard clearContents];
    NSArray *toPasteboard = @[self.passwordField.stringValue];
    BOOL ok = [pasteboard writeObjects:toPasteboard];
    
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
    double ct = strength.crackTime;
    //[10**2, 10**4, 10**6, 10**8, Infinity].
    int i;
    ct = ct/100.0;
    for (i=0;i<11; i++){
        ct = ct/10.0;
        if(ct <=1){
            break;
        }
        
    }
    i--;
    if (i<0) { i = 0;}
    NSLog(@"CT %f",ct);
    if (ct > 1) {ct = 0;}
    ct+=i;
    ct*=10;
    NSLog(@"I Strength %d",i);
    NSLog(@"CT2 %f",ct);
    [self.passwordStrengthLevel setFloatValue:ct];
}





@end
