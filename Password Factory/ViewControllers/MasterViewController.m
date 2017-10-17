//
//  MasterViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "MasterViewController.h"
#import "PasswordStrength.h"
#import "PasswordFactory.h"
#import "PreferencesWindowController.h"
#import "AppDelegate.h"
#import "constants.h"
#import "DefaultsManager.h"
#import "constants.h"

@interface MasterViewController () <NSTabViewDelegate, NSTextFieldDelegate>

@property (nonatomic, strong) id clearClipboardTimer;
@property (nonatomic, strong) Class timerClass;
@property (nonatomic, strong) PasswordStrength *passwordStrength;

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //initialize everything
        self.pf = [[PasswordFactory alloc] init];
        self.passwordStrength = [[PasswordStrength alloc] init];
        self.timerClass = [NSTimer class];
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

        self.colorPasswordText = [d boolForKey:@"colorPasswordText"];

        [self setObservers];
    }
    return self;
}
- (void)awakeFromNib {
    //get the length from the slider
    [self getPasswordLength];
    //sets the delegates for the tab buttons
    [self.passwordTypeTab setDelegate:self];
    [self.patternText setDelegate:self];
    [self.passwordField setDelegate:self];
}
-(void)viewWillAppear {
    [self generatePassword];
}
#pragma mark Observers

/**
 Sets the necessary observers
 */
- (void)setObservers {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSDictionary *p = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    //setting observers for all the items in our defaults plist
    for (NSString *k in p) {
        [d addObserver:self
            forKeyPath:k
               options:NSKeyValueObservingOptionNew
               context:NULL];
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //if the color password checkbox was changed update the display of the password field
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

/**
 Sends string to clipboard

 @param val string to put on the clipboard
 */
- (void)updatePasteboard:(NSString *)val {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *toPasteboard = @[val];
    BOOL ok = [pasteboard writeObjects:toPasteboard];
    if (!ok) { NSLog(@"Write to pasteboard failed");}
}

/**
 Generates many passwords and chooses the strongest and then copies it to the clipboard
 */
- (void)generateAndCopy {
    NSString *pw;
    float s = -1;
    //set the max password generations to GenerateAndCopyLoops
    for(int i = 0; i < GenerateAndCopyLoops; i++) {
        [self generatePassword];
        //choose the stronger one
        if (self.passwordStrengthLevel.strength  > s) {
            s = self.passwordStrengthLevel.strength;
            pw = self.passwordValue;
        }
    }
    //update the password display
    self.passwordValue = pw;
    [self updatePasswordField];
    //Update the password strength - updateStrength takes 0-100 value
    [self.passwordStrengthLevel updateStrength:s * 100];

    //copy to pasteboard
    [self copyToClipboard:nil];
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

    //show the notification ,
    if ([d boolForKey:@"globalHotkeyShowNotification"]) {
        [self displayCopyNotification];
    
    //or play the sound
    } else if ([d boolForKey:@"globalHotkeyPlaySound"]) {
        [[NSSound soundNamed:NotificationSoundName] play];
    }
    
}

/**
 Displays a notification that a password was copied to the notification center
 */
- (void)displayCopyNotification {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:@"Password Copied"];
    [notification setInformativeText:[NSString stringWithFormat:@"Password with strength %2.0f copied to clipboard.",self.passwordStrengthLevel.floatValue ]];
    [notification setDeliveryDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]]];
    //Set the sound if the user configured it
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"globalHotkeyPlaySound"]) {
        [notification setSoundName:NotificationSoundName];
    }
    
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center scheduleNotification:notification];
}

/**
 Copies to clipboard, sets up the clear clipboard timer and closes the window if it is in the menu

 @param sender default IBAction sender
 */
- (IBAction)copyToClipboard:(id)sender {

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

/**
 Loads the preferences window

 @param sender IBAction sender
 */
- (IBAction)loadPreferencesWindow:(id)sender {
    AppDelegate *d = [[NSApplication sharedApplication] delegate];
    [d.prefsWindowController showWindow:sender];
    d.prefsWindowController.window.restorable = YES;
    [NSApp activateIgnoringOtherApps:YES]; //brings it to front
}

/**
 clears the clipboard
 */
- (void)clearClipboard {
    [self updatePasteboard:@""];
}
#pragma mark UI Controls

/**
 Changes the password strength when someone types in the password field, or types in the pattern text field

 @param obj notifcation passed
 */
- (void)controlTextDidChange:(NSNotification *)obj {
    //if the change came from the passwordField, just reset the strength
    //otherwise generate the password
    if(obj.object == self.passwordField) {
        self.passwordValue = self.passwordField.stringValue;
        [self setPasswordStrength];
        [self updatePasswordField];
    } else {
        //the change came from the pattern text field - so generate the password
        [self generatePassword];
    }
}

/**
 Called when the tab view changes - will generate a new password every time

 @param tabView tabView
 @param tabViewItem item clicked
 */
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    //generate a new password
    [self generatePassword];
}

/**
 Radio button clicked on the pronounceable tab - generates password

 @param sender default sender
 */
- (IBAction)pressPrononunceableRadio:(id)sender {
    [self generatePassword];
}


/**
 Called when the length slider is changed - generates password

 @param sender default sender
 */
- (IBAction)changeLength:(id)sender {
    [self getPasswordLength];
}

/**
 Generate button was pressed

 @param sender default sender
 */
- (IBAction)generateAction:(id)sender {
    [self generatePassword];
}

/**
 Gets the set password length from the slider
 */
- (void)getPasswordLength{
    NSUInteger prevLength = self.pf.passwordLength;
    self.pf.passwordLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"passwordLength"];

    if (prevLength != self.pf.passwordLength) { //do not change password unless length changes
        [self generatePassword];
    }
}

/**
 Generates password in the proper format
 */
- (void)generatePassword {
    NSInteger atTab = [self.passwordTypeTab.selectedTabViewItem.identifier intValue];
    //Generates different password formats based upon the selected tab
    switch (atTab) {
        case PFTabRandom: //random
            self.passwordValue = [self.pf generateRandom:[self.mixedCase state]
                                          avoidAmbiguous:[self.avoidAmbiguous state]
                                              useSymbols:[self.useSymbols state]];
            break;
        case PFTabPattern: //pattern
            self.passwordValue = [self.pf generatePattern:self.patternText.stringValue];
            break;
        case PFTabPronounceable: //pronounceable
            self.passwordValue = [self.pf generatePronounceableWithSeparatorType:[self getPronounceableSeparatorType]];
            break;
        case PFTabPassphrase: //passphrase:
            self.passwordValue = [self.pf generatePassphraseWithCode:[self getPassphraseSeparatorType] caseType:[self getPassphraseCaseType]];
            break;
    }
    [self updatePasswordField];
    [self setPasswordStrength];
}

/**
 Gets the passphrase separator type and adds the type to the shared defaults

 @return separator type
 */
- (int)getPassphraseSeparatorType {
    int type = (int)[(NSButtonCell *)[self.passphraseSeparatorRadio selectedCell] tag];
    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"passphraseSeparatorTagShared"];
    return type;
}

/**
 Gets the passphrase case type and adds it to the shared defaults

 @return case type
 */
- (int)getPassphraseCaseType {
    int type = (int)[(NSButtonCell *)[self.passphraseCaseRadio selectedCell] tag];
    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"passphraseCaseTypeTagShared"];
    return type;
}

/**
 Gets the pronounceable separator type and adds it to the shared defaults

 @return separator type
 */
- (int)getPronounceableSeparatorType {
    int type = (int)[(NSButtonCell *)[self.pronounceableSeparatorRadio selectedCell] tag];
    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"pronounceableSeparatorTagShared"];
    return  type;

}

#pragma mark Password Display

/**
 Updates the password field and colors it if user asks
 */
- (void)updatePasswordField{
    [PreferencesWindowController syncSharedDefaults];
    //Just display the password
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
        
        //uses AttributedString to color password
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:self.passwordValue attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13]}];
        NSError *error;
        NSRegularExpression *charRegex = [[NSRegularExpression alloc] initWithPattern:@"[A-Z]" options:0 error:&error];
        NSRegularExpression *charlRegex = [[NSRegularExpression alloc] initWithPattern:@"[a-z]" options:0 error:&error];
        NSRegularExpression *numRegex = [[NSRegularExpression alloc] initWithPattern:@"[0-9]" options:0 error:&error];
        NSRegularExpression *symRegex = [[NSRegularExpression alloc] initWithPattern:@"[^0-9A-Za-z]" options:0 error:&error];
        
        NSRange r = NSMakeRange(0, 1);
        //colorizing password label
        [s beginEditing];
        //loops through the string and uses a regex to determine the color of the character
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
            //set the character color
            [s addAttribute:NSForegroundColorAttributeName
                      value:c
                      range:NSMakeRange(i, 1)];
            
            
        }
        [s endEditing];
        //update the password field
        [self.passwordField setAttributedStringValue:s];
    }
}

/**
 Swaps white and black when depending on dark or light mode, so white will be black on normal, and black will be white on dark

 @param color color to swap
 @return possibly swapped color
 */
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

/**
 Updates the password strength meter and the crack time string
 */
- (void)setPasswordStrength {
    BOOL displayCTS = [[NSUserDefaults standardUserDefaults] boolForKey:@"displayCrackTime"]; //do we want to display the crack time string?
    [self.passwordStrength updatePasswordStrength:self.passwordValue withCrackTimeString:displayCTS];
    [self.passwordStrengthLevel updateStrength:self.passwordStrength.strength];
    //only generate the crack time string if the user has it selected
    if (displayCTS) {
        [self.crackTimeButton setTitle:[self.passwordStrength.crackTimeString uppercaseString]];
    }
    //display the button using the alpha value
    self.crackTimeButton.alphaValue = (int)displayCTS;
}

/**
 Pressed passphrase separator radio button

 @param sender default sender
 */
- (IBAction)pressPassphraseSeparatorRadio:(id)sender {
    [self generatePassword];
}

/**
 Pressed passphrase case radio button

 @param sender default sender
 */
- (IBAction)pressPassphraseCaseRadio:(id)sender {
    [self generatePassword];
}

/**
 Toggles the display of the crack time in the strength bar

 @param sender default sender
 */
- (IBAction)toggleCrackTimeDisplay:(id)sender {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSButton *b = self.crackTimeButton;
    BOOL showCT = ![d boolForKey:@"displayCrackTime"];
    [d setBool:showCT forKey:@"displayCrackTime"]; //manually setting defaults because bindings don't work for this
    if (showCT) { //regenerate the password strength to make sure the values are displaying correctly
        [self setPasswordStrength];
    }
    b.alphaValue = (int)showCT; //the int value of the bool matches the alpha value we need to show and hide the button
    
}
@end
