//
//  MasterViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "MasterViewController.h"
#import "PasswordStrength.h"
#import "PasswordFactory.h"
#import "PreferencesWindowController.h"
#import "AppDelegate.h"
#import "constants.h"
#import "DefaultsManager.h"

int const  GenerateAndCopyLoops  = 10;
@interface MasterViewController () <NSTabViewDelegate, NSTextFieldDelegate>

@property (nonatomic, strong) id clearClipboardTimer;
@property (nonatomic, strong) Class timerClass;
@property (nonatomic, strong) PasswordStrength *passwordStrength;
@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.pg = [[PasswordFactory alloc] init];
        self.passwordStrength = [[PasswordStrength alloc] init];
        self.timerClass = [NSTimer class];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

        self.colorPasswordText = [d boolForKey:@"colorPasswordText"];


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
#pragma mark Observers
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
    }
    //Updating the password field when the color well changes to enable live color updating
    if (self.colorPasswordText &&
        ([keyPath isEqualToString:@"upperTextColor"] ||
         [keyPath isEqualToString:@"lowerTextColor"] ||
         [keyPath isEqualToString:@"numberTextColor"] ||
         [keyPath isEqualToString:@"symbolTextColor"])
        ) {
        [self updatePasswordField];
    }
    
}
#pragma mark Clipboard Handling
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
        if (self.passwordStrengthLevel.strength  > s) {
            s = self.passwordStrengthLevel.strength;
            pw = self.passwordValue;
        }
    }
    self.passwordValue = pw;
    [self updatePasswordField];
    //updateStrength takes 0-100 value
    [self.passwordStrengthLevel updateStrength:s * 100];

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
    [notification setInformativeText:[NSString stringWithFormat:@"Password with strength %2.0f copied to clipboard.",self.passwordStrengthLevel.floatValue ]];
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
        //setting up clear clipboard timer
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
    //closing window if it is a menuApp
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
        NSWindow *window = [[NSApplication sharedApplication] mainWindow];
        if (window.isVisible) {
            [window close];
        }
    }
    
}
- (IBAction)loadPreferences:(id)sender {
    AppDelegate *d = [[NSApplication sharedApplication] delegate];
    [d.prefsWindowController showWindow:sender];
    [NSApp activateIgnoringOtherApps:YES]; //brings it to front
}
- (void)clearClipboard {
    [self updatePasteboard:@""];
}
#pragma mark UI Controls
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


- (void)getPasswordLength{

    NSUInteger prevLength = self.pg.passwordLength;
    self.pg.passwordLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"passwordLength"];


    if (prevLength != self.pg.passwordLength) { //do not change password unless length changes
        [self generatePassword];
    }
    
}

- (void)generatePassword {
    NSInteger atTab = [self.passwordTypeTab.selectedTabViewItem.identifier intValue];


    switch (atTab) {
        case 0: //random
            self.passwordValue = [self.pg generateRandom:[self.mixedCase state]
                                          avoidAmbiguous:[self.avoidAmbiguous state]
                                              useSymbols:[self.useSymbols state]];
            break;
        case 1: //pattern
            self.passwordValue = [self.pg generatePattern:self.patternText.stringValue];
            break;
        case 2: //pronounceable
            self.passwordValue = [self.pg generatePronounceableWithSeparatorType:[self getPronounceableSeparatorType]];
            break;
        case 3: //passphrase:
            self.passwordValue = [self.pg generatePassphraseWithCode:[self getPassphraseSeparatorType] caseType:[self getPassphraseCaseType]];
            break;
    }
    [self updatePasswordField];
    [self setPasswordStrength];
    
    
}
//When getting the radio selections, the tag is added to the shared defaults
//because the bindings do not use tags, they use the position value
- (int)getPassphraseSeparatorType {
    int type = (int)[(NSButtonCell *)[self.passphraseSeparatorRadio selectedCell] tag];
    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"passphraseSeparatorTagShared"];

    return type;
    
}
- (int)getPassphraseCaseType {
    int type = (int)[(NSButtonCell *)[self.passphraseCaseRadio selectedCell] tag];
    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"passphraseCaseTypeTagShared"];
    return type;
}
- (int)getPronounceableSeparatorType {
    int type = (int)[(NSButtonCell *)[self.pronounceableSeparatorRadio selectedCell] tag];
    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"pronounceableSeparatorTagShared"];
    return  type;

}

#pragma mark Password Display
- (void)updatePasswordField{
    [PreferencesWindowController syncSharedDefaults];
    if (!self.colorPasswordText) {
        NSAttributedString *s = [[NSAttributedString alloc] initWithString:self.passwordValue attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}];
        [self.passwordField setAttributedStringValue: s];
    } else {
        //colors the password text based upon color wells in preferences
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        

        
        
        NSColor *nColor = [PreferencesWindowController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"numberTextColor"]]];
        NSColor *cColor = [PreferencesWindowController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"upperTextColor"]]];
        NSColor *clColor = [PreferencesWindowController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"lowerTextColor"]]];
        NSColor *sColor = [PreferencesWindowController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"symbolTextColor"]]];


 
        
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
//the program will swap white and black for more legibility
-(NSString *)swapColorForDisplay:(NSString *)color {
    NSString *white = @"FFFFFF";
    NSString *black  = @"000000";
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
        if ([AppDelegate isDarkMode]) {
            if ([color isEqualToString:black]) {
                return white;
            }
        } else {
            if ([color isEqualToString:white]) {
                return black;
            }
        }
    } else if ([color isEqualToString:white]) {
        return black;
    }

    return color;
}
#pragma mark Password Strength
- (void)setPasswordStrength {


    [self.passwordStrengthLevel updateStrength:
     [self.passwordStrength
      getStrengthForPasswordType:
        [self.passwordTypeTab.selectedTabViewItem.identifier intValue]
        password:self.passwordValue]];


}


        
- (IBAction)pressPassphraseSeparatorRadio:(id)sender {
    [self generatePassword];
}

- (IBAction)pressPassphraseCaseRadio:(id)sender {
    [self generatePassword];
}
@end
