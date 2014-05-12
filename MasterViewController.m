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
    [self.passwordTypeTab setDelegate:self];
    [self.patternText setDelegate:self];
    [self.passwordField setDelegate:self];
    
}
- (IBAction)copyToPasteboard:(id)sender {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *toPasteboard = @[self.passwordField.stringValue];
    BOOL ok = [pasteboard writeObjects:toPasteboard];
    if (!ok) { NSLog(@"Write to pasteboard failed");}
    
}
- (void)controlTextDidChange:(NSNotification *)obj {
    //if the change came from the passwordField, just reset the strength
    //otherwise generate the password
    if(obj.object == self.passwordField) {
        [self setPasswordStrength:[self.passwordField stringValue]];
    } else {
        [self generatePassword];
    }
    
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
    [self updatePasswordField:passwordValue];
    [self setPasswordStrength:passwordValue];
    
    
}
- (void)updatePasswordField:(NSString *)passwordValue {
    NSColor *nColor = [NSColor magentaColor];
    NSColor *cColor = [NSColor blackColor];
    NSColor *clColor = [NSColor darkGrayColor];
    NSColor *sColor = [NSColor purpleColor];

    
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:passwordValue attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}];
    NSError *error;
    NSRegularExpression *charRegex = [[NSRegularExpression alloc] initWithPattern:@"[A-Z]" options:0 error:&error];
    NSRegularExpression *charlRegex = [[NSRegularExpression alloc] initWithPattern:@"[a-z]" options:0 error:&error];
    NSRegularExpression *numRegex = [[NSRegularExpression alloc] initWithPattern:@"[0-9]" options:0 error:&error];
    NSRegularExpression *symRegex = [[NSRegularExpression alloc] initWithPattern:@"[^0-9A-Za-z]" options:0 error:&error];
    
    NSRange r = NSMakeRange(0, 1);
    //colorzing password label
    [s beginEditing];
    for (int i=0; i < passwordValue.length ; i++) {
        NSColor *c = [NSColor blueColor];
        NSString *at = [NSString stringWithFormat:@"%c",[passwordValue characterAtIndex:i]];
        NSLog(@"LOOP: %d AT:%@",i,at);
        if ([charRegex matchesInString:at options:0 range:r].count) {
            c = cColor;
        } else if ([charlRegex matchesInString:at options:0 range:r].count){
            c = clColor;
        } else if ([numRegex matchesInString:at options:0 range:r].count){
            c = nColor;
        } else if ([symRegex matchesInString:at options:0 range:r].count){
            c = sColor;
        }

        [s addAttribute:NSForegroundColorAttributeName
                       value:c
                       range:NSMakeRange(i, 1)];


    }
    [s endEditing];
    //    [self.passwordField setStringValue: passwordValue];
    [self.passwordField setAttributedStringValue:s];
}
- (NSString *)getPronounceableRadioSelected {
    NSButtonCell *selected = [[self pronounceableSeparatorRadio] selectedCell];
    return [(NSString *)selected.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
}
- (void)setPasswordStrength:(NSString *)password {
    BBPasswordStrength *strength = [[BBPasswordStrength alloc] initWithPassword:password];
    //playing around with numbers to make a good scale
    double ct = log10(strength.crackTime);
    //tweaking output based on password type
    switch ([self.passwordTypeTab.selectedTabViewItem.identifier intValue]) {
        case 0: //random
            ct = (ct/40)*100;
            break;
        case 1: //pattern
            
            ct = (ct/10)*100;
            break;
        case 2: //pronounceable
            ct = (ct/40)*100;
            break;
    }
    
    
    if (ct > 100) {ct = 100;}
    [self.passwordStrengthLevel setFloatValue:ct];
}

@end
