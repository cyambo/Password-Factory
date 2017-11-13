//
//  MasterViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "MasterViewController.h"
#import "PreferencesViewController.h"
#import "DefaultsManager.h"
#import "AppDelegate.h"
#import "constants.h"
#import "DefaultsManager.h"
#import "StyleKit.h"


@interface MasterViewController () <NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource, PasswordControllerDelegate>

@property (nonatomic, strong) id clearClipboardTimer;
@property (nonatomic, assign) NSUInteger passwordLength;
@property (nonatomic, strong) NSDictionary *typeImages;
@property (nonatomic, weak) PasswordTypesViewController *currentPasswordTypeViewController;
@property (nonatomic, assign) NSUInteger currentFontSize;
@end

@implementation MasterViewController

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        //initialize everything
        self.password = [PasswordController get];
        self.password.delegate = self;
        [self setOptionalTypes];
        NSUserDefaults *d = [DefaultsManager standardDefaults];
        self.colorPasswordText = [d boolForKey:@"colorPasswordText"];
        self.typeImages = @{
                            @(PFRandomType): [StyleKit imageOfRandomType],
                            @(PFPronounceableType): [StyleKit imageOfPronounceableType],
                            @(PFPassphraseType): [StyleKit imageOfPassphraseType],
                            @(PFPatternType): [StyleKit imageOfPatternType],
                            @(PFAdvancedType): [StyleKit imageOfAdvancedType],
                            @(PFStoredType): [StyleKit imageOfStoredType]
                            };
        self.currentFontSize = 13;
        [self setObservers];
    }
    return self;
}
- (void)awakeFromNib {
    [self.passwordField setDelegate:self];
}
-(void)viewWillAppear {
    [self setOptionalTypes];
    PFPasswordType type = (PFPasswordType)[[DefaultsManager standardDefaults] integerForKey:@"selectedPasswordType"];
    [self selectPaswordType:type];
    [self generatePassword];
    self.currentFontSize = [(NSNumber *)[[self.passwordField font].fontDescriptor objectForKey:NSFontSizeAttribute] integerValue];
    NSLog(@"CURRENT FONT SIZE %d",self.currentFontSize);
}

#pragma mark Observers

/**
 Sets the necessary observers
 */
- (void)setObservers {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSDictionary *p = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    //setting observers for all the items in our defaults plist
    for (NSString *k in p) {
        [d addObserver:self forKeyPath:k options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //if the color password checkbox was changed update the display of the password field
    if ([keyPath isEqualToString:@"colorPasswordText"]) {
        self.colorPasswordText = [object boolForKey:keyPath];
        [self updatePasswordField];
    }
    //update the color if the default color changes
    if ([keyPath isEqualToString:@"defaultTextColor"]) {
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
    
    //updates the max length for the currerntly visible password type
    if ([keyPath isEqualToString:@"maxPasswordLength"] && change[@"new"] != nil && change[@"new"] != [NSNull null]) {
        float new = [(NSNumber *)change[@"new"] floatValue];
        //updating the max password length slider when the max password length value has changed from preferences
        if (self.currentPasswordTypeViewController.passwordLengthSlider) {
            NSSlider *slider = self.currentPasswordTypeViewController.passwordLengthSlider;
            [self updateForMaxPasswordLength:new slider:slider key:@"passwordLength"];
            [self.currentPasswordTypeViewController changeLength:slider];
        }
        //updating the truncate slider
        if (self.currentPasswordTypeViewController.advancedTruncate) {
            NSSlider *slider = self.currentPasswordTypeViewController.advancedTruncate;
            [self updateForMaxPasswordLength:new slider:slider key:@"advancedTruncateAt"];
            [self.currentPasswordTypeViewController changeAdvancedTruncate:slider];
        }
    }
    if ([keyPath isEqualToString:@"enableAdvanced"] || [keyPath isEqualToString:@"storePasswords"]) {
        [self setOptionalTypes];
        [self.passwordTypesTable reloadData];
    }

}
-(void)updateForMaxPasswordLength:(float)new slider:(NSSlider *)slider key:(NSString *)key {
    if (slider.maxValue != new) {
        float currValue = slider.floatValue;
        if (currValue > new) {
            [[DefaultsManager standardDefaults] setFloat:new forKey:key];
        }
        slider.maxValue = new;
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
    float s = -1;
    //set the max password generations to GenerateAndCopyLoops
    for(int i = 0; i < GenerateAndCopyLoops; i++) {
        [self generatePassword];
        //choose the stronger one
        if (self.passwordStrengthLevel.strength  > s) {
            s = [self.password getPasswordStrength];
            [self.password getPasswordValue];
        }
    }
    //update the password display
    [self updatePasswordField];
    //Update the password strength - updateStrength takes 0-100 value
    [self.passwordStrengthLevel updateStrength:s * 100];

    //copy to pasteboard
    [self copyToClipboard:nil];
    
    NSUserDefaults *d = [DefaultsManager standardDefaults];

    //show the notification ,
    if ([d boolForKey:@"globalHotkeyShowNotification"]) {
        [self displayCopyNotification];
    
    //or play the sound
    } else if ([d boolForKey:@"globalHotkeyPlaySound"]) {
        [[NSSound soundNamed:[self getSelectedSoundName]] play];
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
    if ([[DefaultsManager standardDefaults] boolForKey:@"globalHotkeyPlaySound"]) {
        [notification setSoundName:[self getSelectedSoundName]];
    }
    
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center scheduleNotification:notification];
}

/**
 Gets the selected notification sound name, or returns the default

 @return notification sound
 */
-(NSString *)getSelectedSoundName {
    NSString *soundName = [[DefaultsManager standardDefaults] stringForKey:@"notificationSound"];
    if (soundName) {
        return soundName;
    }
    return NotificationSoundName;
}
/**
 Copies to clipboard, sets up the clear clipboard timer and closes the window if it is in the menu

 @param sender default IBAction sender
 */
- (IBAction)copyToClipboard:(id)sender {

    NSUserDefaults *d = [DefaultsManager standardDefaults];
    [self updatePasteboard:[self.password getPasswordValue]];
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
    if ([[DefaultsManager standardDefaults] boolForKey:@"isMenuApp"]) {
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
    [self.prefsWindowController showWindow:sender];
    self.prefsWindowController.window.restorable = YES;

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
        [self.password setPasswordValue: self.passwordField.stringValue];
        [self.password updatePasswordStrength];
        [self setPasswordStrength];
        [self updatePasswordField];
    } else {
        [self generatePassword];
    }
}

/**
 Generate button was pressed

 @param sender default sender
 */
- (IBAction)generateAction:(id)sender {
    [self generatePassword];
}

/**
 Generates password in the proper format
 */
- (void)generatePassword {
    [self.password generatePassword:[self getSelectedPasswordType]];
    [self updatePasswordField];
    [self setPasswordStrength];
}

/**
 Password Controller Delegate method called when password is updated in PasswordController

 @param password updated password
 */
-(void)passwordChanged:(NSString *)password {
    [self updatePasswordField];
    [self setPasswordStrength];
}
#pragma mark Password Display

/**
 Updates the password field and colors it if user asks
 */
- (void)updatePasswordField{
    [[DefaultsManager get] syncSharedDefaults];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    //default text color from prefs
    NSColor *dColor = [PreferencesViewController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"defaultTextColor"]]];
    NSString *currPassword = [self.password getPasswordValue];
    if (currPassword == nil || currPassword.length == 0) {
        [self.passwordField setAttributedStringValue:[[NSAttributedString alloc] init]];
        return;
    }
    
    //Just display the password
    if (!self.colorPasswordText) {
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName: dColor,
                                     NSFontAttributeName: [NSFont systemFontOfSize:self.currentFontSize]
                                     };
        NSAttributedString *s = [[NSAttributedString alloc] initWithString:currPassword attributes:attributes];
        [self.passwordField setAttributedStringValue: s];
    } else {
        //colors the password text based upon color wells in preferences
        
        NSColor *nColor = [PreferencesViewController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"numberTextColor"]]];
        NSColor *cColor = [PreferencesViewController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"upperTextColor"]]];
        NSColor *clColor = [PreferencesViewController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"lowerTextColor"]]];
        NSColor *sColor = [PreferencesViewController colorWithHexColorString:[self swapColorForDisplay:[d objectForKey:@"symbolTextColor"]]];
        
        //uses AttributedString to color password
        
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:currPassword attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:self.currentFontSize]}];

        //colorizing password label
        [s beginEditing];
        //loops through the string and sees if it is in each type of string to determine the color of the character
        //using 'NSStringEnumerationByComposedCharacterSequences' so that emoji and other extended characters are enumerated as a single character
        [currPassword enumerateSubstringsInRange:NSMakeRange(0, currPassword.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable at, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            NSColor *c = dColor; //set a default color of the text to the default color
            if(substringRange.length == 1) { //only color strings with length of one, anything greater is an emoji or other long unicode charcacters
                if ([self.password isCharacterType:PFUpperCaseLetters character:at]) { //are we an uppercase character
                    c = cColor;
                } else if ([self.password isCharacterType:PFLowerCaseLetters character:at]){ //lowercase character?
                    c = clColor;
                } else if ([self.password isCharacterType:PFNumbers character:at]){ //number?
                    c = nColor;
                } else if ([self.password isCharacterType:PFSymbols character:at]){ //symbol?
                    c = sColor;
                } else {
                    c = dColor;
                }
                //set the character color
                [s addAttribute:NSForegroundColorAttributeName value:c range:substringRange];
            }
        }];

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
    if ([[DefaultsManager standardDefaults] boolForKey:@"isMenuApp"]) {
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
    BOOL displayCTS = [[DefaultsManager standardDefaults] boolForKey:@"displayCrackTime"]; //do we want to display the crack time string?
    self.password.generateCrackTimeString = displayCTS;
    [self.passwordStrengthLevel updateStrength:[self.password getPasswordStrength]];
    //only display the crack time string if the user has it selected
    if (displayCTS) {
        [self.crackTimeButton setTitle:[[self.password getCrackTimeString] uppercaseString]];
    }
    //display the button using the alpha value
    self.crackTimeButton.alphaValue = (int)displayCTS;
}


/**
 Sets the optional password types in the Password controller so that the type display works properly
 */
-(void)setOptionalTypes {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    self.password.useStoredType = [d boolForKey:@"storePasswords"];
    self.password.useAdvancedType = [d boolForKey:@"enableAdvanced"];
}

/**
 Toggles the display of the crack time in the strength bar

 @param sender default sender
 */
- (IBAction)toggleCrackTimeDisplay:(id)sender {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    NSButton *b = self.crackTimeButton;
    BOOL showCT = ![d boolForKey:@"displayCrackTime"];
    [d setBool:showCT forKey:@"displayCrackTime"]; //manually setting defaults because bindings don't work for this
    if (showCT) { //regenerate the password strength to make sure the values are displaying correctly
        [self setPasswordStrength];
    }
    b.alphaValue = (int)showCT; //the int value of the bool matches the alpha value we need to show and hide the button
}
- (PFPasswordType)getSelectedPasswordType {
    NSInteger row = self.passwordTypesTable.selectedRow;
    return [self.password getPasswordTypeByIndex:row];
}
-(void)selectPaswordType:(PFPasswordType)type {
    NSInteger row = self.passwordTypesTable.selectedRow;
    PFPasswordType currType = [self.password getPasswordTypeByIndex:row];
    if (currType == type && row >= 0) {
        [self generatePassword];
    } else {
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:[self.password getIndexByPasswordType:type]];
        [self.passwordTypesTable selectRowIndexes:set byExtendingSelection:false];
    }
}
#pragma mark Table View
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self.password getFilteredPasswordTypes] count];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *c = [tableView makeViewWithIdentifier:@"Password Type Cell" owner:nil];
    PFPasswordType type = [self.password getPasswordTypeByIndex:row];
    c.textField.stringValue = [self.password getNameForPasswordType:type];
    c.imageView.image = self.typeImages[@(type)];
    return c;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = self.passwordTypesTable.selectedRow;
    PFPasswordType type = [self.password getPasswordTypeByIndex:row];
    [[DefaultsManager standardDefaults] setInteger:type forKey:@"selectedPasswordType"];
    PasswordTypesViewController *vc = [self.password getViewControllerForPasswordType:type];
    self.currentPasswordTypeViewController = vc;
    self.passwordView.subviews = @[];
    [self.passwordView addSubview:vc.view];
    [self generatePassword];
}
@end
