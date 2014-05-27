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
#import "PreferencesWindowController.h"
#import "AppDelegate.h"
int const  GenerateAndCopyLoops  = 10;
@interface MasterViewController () <NSTabViewDelegate, NSTextFieldDelegate>




@property (nonatomic, strong) id clearClipboardTimer;
@property (nonatomic, strong) Class timerClass;

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pg = [[PasswordGenerator alloc] init];
        self.timerClass = [NSTimer class];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

        self.colorPasswordText = [d boolForKey:@"colorPasswordText"];
        if (self.colorPasswordText == nil) {
            NSLog(@"NIL");
        }
        [self setObservers];
    }
    return self;
}
- (void)awakeFromNib {
    [self getPasswordLength];
    [self.passwordTypeTab setDelegate:self];
    [self.patternText setDelegate:self];
    [self.passwordField setDelegate:self];
    
}
//not using the global observer because it does not send what was changed
- (void)setObservers {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSDictionary *p = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    //taking plist and filling in defaults if none set
    for (NSString *k in p) {
        [d addObserver:self
            forKeyPath:k
               options:NSKeyValueObservingOptionNew
               context:NULL];
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"colorPasswordText"]) {
        self.colorPasswordText = [object boolForKey:keyPath];
        [self updatePasswordField];
    } else if(
        [keyPath isEqualToString:@"clearClipboard"] ||
        [keyPath isEqualToString:@"clearClipboardTime"]) {
        //do nothing for now
    } else {
        if (self.colorPasswordText ) {
            [self updatePasswordField];
        }
    }
}
- (void)updatePasteboard:(NSString *)val {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *toPasteboard = @[val];
    BOOL ok = [pasteboard writeObjects:toPasteboard];
    if (!ok) { NSLog(@"Write to pasteboard failed");}
}
- (void)generateAndCopy {
    NSString *pw;
    float s = -1;
    for(int i = 0; i < GenerateAndCopyLoops; i++) {
        [self generatePassword];
        if (self.passwordStrengthLevel.floatValue  > s) {
            s = self.passwordStrengthLevel.floatValue;
            pw = self.passwordValue;
        }
    }
    self.passwordValue = pw;
    [self updatePasswordField];
    [self.passwordStrengthLevel setFloatValue:s];
    [self copyToPasteboard:nil];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];


    if ([d boolForKey:@"globalHotkeyShowNotification"]) {
        [self displayCopyNotification];
        
    } else if ([d boolForKey:@"globalHotkeyPlaySound"]) {
        [[NSSound soundNamed:@"Hero"] play];
    }
    
}

- (void)displayCopyNotification {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:@"Password Copied"];
    [notification setInformativeText:[NSString stringWithFormat:@"Password with strength %2.0f copied to clipboard.",self.passwordStrengthLevel.floatValue]];
    [notification setDeliveryDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]]];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"globalHotkeyPlaySound"]) {
        [notification setSoundName:NSUserNotificationDefaultSoundName];
    }
    
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center scheduleNotification:notification];
}
- (IBAction)copyToPasteboard:(id)sender {

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [self updatePasteboard:self.passwordValue];
    if ([d boolForKey:@"clearClipboard"]) {
        if ([self.clearClipboardTimer isValid]) {
            [self.clearClipboardTimer invalidate];
        }
        self.clearClipboardTimer =
        [NSTimer scheduledTimerWithTimeInterval:[d integerForKey:@"clearClipboardTime"]
                                         target:self
                                       selector:@selector(clearClipboard)
                                       userInfo:nil
                                        repeats:NO];
        
    }
}
- (void)clearClipboard {
    [self updatePasteboard:@""];
}
- (void)controlTextDidChange:(NSNotification *)obj {
    //if the change came from the passwordField, just reset the strength
    //otherwise generate the password
    if(obj.object == self.passwordField) {
        self.passwordValue = self.passwordField.stringValue;
        [self setPasswordStrength];
        [self updatePasswordField];
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
    [self getButtonStates];
    switch (atTab) {
        case 0: //random
            self.passwordValue = [self.pg generateRandom];
            break;
        case 1: //pattern
            self.passwordValue = [self.pg generatePattern:self.patternText.stringValue];
            break;
        case 2: //pronounceable
            self.passwordValue = [self.pg generatePronounceable:[self getPronounceableRadioSelected]];
            break;
    }
    [self updatePasswordField];
    [self setPasswordStrength];
    
    
}
- (void)updatePasswordField{

    if (!self.colorPasswordText) {
        NSAttributedString *s = [[NSAttributedString alloc] initWithString:self.passwordValue attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}];
        [self.passwordField setAttributedStringValue: s];
    } else {
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        
        NSColor *nColor = [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"numberTextColor"]];
        NSColor *cColor = [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"upperTextColor"]];
        NSColor *clColor = [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"lowerTextColor"]];
        NSColor *sColor = [PreferencesWindowController colorWithHexColorString:[d objectForKey:@"symbolTextColor"]];

        
        
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:self.passwordValue attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}];
        NSError *error;
        NSRegularExpression *charRegex = [[NSRegularExpression alloc] initWithPattern:@"[A-Z]" options:0 error:&error];
        NSRegularExpression *charlRegex = [[NSRegularExpression alloc] initWithPattern:@"[a-z]" options:0 error:&error];
        NSRegularExpression *numRegex = [[NSRegularExpression alloc] initWithPattern:@"[0-9]" options:0 error:&error];
        NSRegularExpression *symRegex = [[NSRegularExpression alloc] initWithPattern:@"[^0-9A-Za-z]" options:0 error:&error];
        
        NSRange r = NSMakeRange(0, 1);
        //colorzing password label
        [s beginEditing];
        for (int i=0; i < self.passwordValue.length ; i++) {
            NSColor *c = [NSColor blueColor];
            NSString *at = [NSString stringWithFormat:@"%c",[self.passwordValue characterAtIndex:i]];
            
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
        [self.passwordField setAttributedStringValue:s];
    }

    
}
- (NSString *)getPronounceableRadioSelected {
    NSButtonCell *selected = [[self pronounceableSeparatorRadio] selectedCell];
    return [(NSString *)selected.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
}
- (void)setPasswordStrength {
    BBPasswordStrength *strength = [[BBPasswordStrength alloc] initWithPassword:self.passwordValue];
    //playing around with numbers to make a good scale
    double ct = log10(strength.crackTime);
    //tweaking output based on password type
    switch ([self.passwordTypeTab.selectedTabViewItem.identifier intValue]) {
        case 0: //random
            ct = (ct/40)*100;
            break;
        case 1: //pattern
            
            ct = (ct/20)*100;
            break;
        case 2: //pronounceable
            ct = (ct/40)*100;
            break;
    }
    
    
    if (ct > 100) {ct = 100;}
    [self.passwordStrengthLevel setFloatValue:ct];
}

@end
