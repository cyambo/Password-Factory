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
#import "NSString+ColorWithHexColorString.h"
#import "NSString+UnicodeLength.h"
#import "PasswordStorage.h"
#import "PasswordFactoryConstants.h"
#import "TypeIcons.h"
#import "Utilities.h"

@interface MasterViewController () <NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource, PasswordControllerDelegate>

@property (nonatomic, strong) id clearClipboardTimer;
@property (nonatomic, assign) NSUInteger passwordLength;
@property (nonatomic, weak) PasswordTypesViewController *currentPasswordTypeViewController;
@property (nonatomic, assign) NSUInteger currentFontSize;
@property (nonatomic, assign) NSTimeInterval lastGenerated;
@property (nonatomic, strong) NSTimer *passwordCheckTimer;
@property (nonatomic, assign) BOOL stored;
@property (nonatomic, strong) NSString *lastStoredPassword;
@property (nonatomic, strong) PasswordStorage *storage;
@property (nonatomic, strong) PasswordFactoryConstants *c;
@property (nonatomic, strong) NSRegularExpression *extendedCharacterRegex;
@end

@implementation MasterViewController

- (instancetype)initWithCoder:(NSCoder *)coder{
    
    self = [super initWithCoder:coder];
    if (self) {
        //initialize everything
        self.password = [PasswordController get:NO];
        self.password.delegate = self;
        [self setOptionalTypes];
        NSUserDefaults *d = [DefaultsManager standardDefaults];
        self.colorPasswordText = [d boolForKey:@"colorPasswordText"];
        self.currentFontSize = 13;
        [self setObservers];
        self.stored = NO;
        self.storage = [PasswordStorage get];
        self.c = [PasswordFactoryConstants get];
        NSString *regex = [NSString stringWithFormat:@"([^A-Za-z0-9%@])",self.c.escapedSymbols];
        NSError *error;
        self.extendedCharacterRegex = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
        NSLog(@"ERROR %@",error.localizedDescription);
    }
    
    return self;
}
- (void)awakeFromNib {
    [self.passwordField setDelegate:self];

}
-(void)viewWillAppear {
    [self setOptionalTypes];
    [self setStorePasswordTimer];
    [self loadTypes];

}
- (void)viewDidAppear {
    [self selectPaswordType:(PFPasswordType)[[DefaultsManager standardDefaults] integerForKey:@"selectedPasswordType"]];
}
-(void)viewWillDisappear {
    [self unsetStorePasswordTimer];
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
    if (change[@"new"] == [NSNull null]) {
        return;
    }
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
        [self loadTypes];
        [self selectPaswordType:[self getSelectedPasswordType]];
    }

}
-(void)loadTypes {
    if(self.passwordTypesTable) {
        [self.passwordTypesTable reloadData];
    } else if (self.passwordTypeControl) {
        NSUInteger count = [[self.password getFilteredPasswordTypes] count];
        [self.passwordTypeControl setSegmentCount:count];
        for(NSUInteger i = 0; i < count; i++) {
            PFPasswordType type = [self.password getPasswordTypeByIndex:i];
            [self.passwordTypeControl setImage:[TypeIcons getAlternateTypeIcon:type] forSegment:i];
            [self.passwordTypeControl setWidth:48.0 forSegment:i];
//            [self.passwordTypeControl setLabel:[self.password getNameForPasswordType:type]  forSegment:i];
        }
    }
}
/**
 Updates slider when the maxPasswordLength changed

 @param new new max
 @param slider NSSlider to update
 @param key defaults key
 */
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

    //show the notification
    if ([d boolForKey:@"globalHotkeyShowNotification"]) {
        [self displayCopyNotification];
    }
    //play the sound
    if ([d boolForKey:@"globalHotkeyPlaySound"]) {
        [[NSSound soundNamed:[self getSelectedSoundName]] play];
    }
    //store password because we wanted to generate it
    [self storePassword];
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
    //store password because we wanted to generate it
    [self storePassword];
}

/**
 Generates password in the proper format
 */
- (void)generatePassword {
    [self.password generatePassword:[self getSelectedPasswordType]];
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
    //set properties for the password storage timer
    self.lastGenerated = [[NSDate date] timeIntervalSince1970];
    self.stored = NO;
    self.currentFontSize = [(NSNumber *)[[self.passwordField font].fontDescriptor objectForKey:NSFontSizeAttribute] integerValue];
    NSString *currPassword = [self.password getPasswordValue];

    [self.displayedPasswordLength setStringValue:[NSString stringWithFormat:@"%lu",[currPassword getUnicodeLength]]];
    if (currPassword == nil || currPassword.length == 0) {
        [self.passwordField setAttributedStringValue:[[NSAttributedString alloc] init]];
        return;
    }
    NSAttributedString *s = [Utilities colorText:currPassword size:self.currentFontSize];
    
    //don't run the check if we are hiding the warning
    if(![[DefaultsManager standardDefaults] boolForKey:@"hideExtendedCharacterWarning"]) {
        NSArray *m = [self.extendedCharacterRegex matchesInString:currPassword options:0 range:NSMakeRange(0, currPassword.length)];
        if (m.count) {
            [self.alertWindowController displayAlert:ExtendedCharacterWarning defaultsKey:@"hideExtendedCharacterWarning"];
        }
    }

    [self.passwordField setAttributedStringValue:s];
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
#pragma mark Utilities
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
 Called when the zoom password button is pressed, will display the ZoomWindow

 @param sender default sender
 */
- (IBAction)zoomPassword:(id)sender {
    [self.zoomWindowController showWindow:sender];
    self.zoomWindowController.window.restorable = YES;
    ZoomViewController *zv = (ZoomViewController *)self.zoomWindowController.contentViewController;
    NSString *password;
    //if we sent a string, show that
    if ([sender isKindOfClass:[NSString class]]) {
        password = sender;
    } else {
        password = [self.passwordField stringValue];
    }
    [zv updatePassword:password];
    [NSApp activateIgnoringOtherApps:YES]; //brings it to front
    [self.zoomWindowController.window makeKeyAndOrderFront:nil];
}

/**
 Gets the current password type

 @return current PFPasswordType
 */
- (PFPasswordType)getSelectedPasswordType {
    NSUInteger index = 0;
    if (self.passwordTypesTable) {
        index = self.passwordTypesTable.selectedRow;
    } else if (self.passwordTypeControl) {
        index = self.passwordTypeControl.selectedSegment;
    }

    return [self.password getPasswordTypeByIndex:index];
}

/**
 Selects the password type in the type selection table

 @param type PFPasswordType to select
 */
-(void)selectPaswordType:(PFPasswordType)type {

    PFPasswordType currType = [self getSelectedPasswordType];
    if (currType == type && self.passwordView.subviews.count) {
        [self generatePassword];
    } else {
        if (self.passwordTypesTable) {
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:[self.password getIndexByPasswordType:type]];
            [self.passwordTypesTable selectRowIndexes:set byExtendingSelection:false];
        } else if (self.passwordTypeControl) {
            NSUInteger index = [self.password getIndexByPasswordType:type];
            [self.passwordTypeControl setSelectedSegment:index];
            [self changeSelectionTypeByIndex:index];
        }
    }

}
#pragma mark Password Storage
-(void)setStorePasswordTimer {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    if ([d boolForKey:@"storePasswords"]) {
        //setting a timer that will check the password field every second to see if it was updated
        //I am using a timer because we don't want to store passwords while sliders, or steppers are being used
        self.passwordCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self storePasswordFromTimer];
        }];
    }

}
-(void)unsetStorePasswordTimer {
    if (self.passwordCheckTimer) {
        [self.passwordCheckTimer invalidate];
    }
}
/**
 Stores the password in PasswordStorage (called from timer, so checks are done to make sure we need to store it
 */
-(void)storePasswordFromTimer {
    //did we store it?
    if (!self.stored) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        //was it after the last time? (but not too soon, because if we just used a greater than it will store way more than we need
        if ((now - self.lastGenerated) > 0.1){
            [self storePassword];
        }
    }
}
-(void)enableStoredPasswords {
    [self setStorePasswordTimer];
}
-(void)disableStoredPasswords {
    [self unsetStorePasswordTimer];
    [self.storage deleteAllEntities];
}
/**
 Store a password in PasswordStorage
 */
-(void)storePassword {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    if ([d boolForKey:@"storePasswords"]) {
        PFPasswordType currType = [self getSelectedPasswordType];
        //don't store anything if we are on the stored type
        if (currType != PFStoredType) {
            //check to see if we stored the same password before
            NSString *curr = [self.password getPasswordValue];
            if (![curr isEqualToString:self.lastStoredPassword]) {
                //all good, so store it
                self.stored = YES;
                [self.storage storePassword:curr strength:[self.password getPasswordStrength] type:currType];
                self.lastStoredPassword = curr;
            }
        }
        self.stored = YES;
    }
}
-(void)deleteStoredPassword {
    PFPasswordType currType = [self getSelectedPasswordType];
    if (currType == PFStoredType) {
        NSUInteger index = self.currentPasswordTypeViewController.storedPasswordTable.selectedRow;
        [self.storage deleteItemAtIndex:index];
        [self.currentPasswordTypeViewController.storedPasswordTable reloadData];
        NSUInteger count = [self.storage count];
        if (count && index < count) {
            [self.currentPasswordTypeViewController selectFromStored:index];
        }
    }
}

- (IBAction)changePasswordTypeControl:(NSSegmentedControl *)sender {
    [self changeSelectionTypeByIndex:sender.selectedSegment];
}

/**
 Changes the current selection type view by index

 @param index index of selected item
 */
- (void)changeSelectionTypeByIndex:(NSUInteger)index {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    PFPasswordType type = [self.password getPasswordTypeByIndex:index];
    //only change if the type selection changed, or we have no subviews (meaning nothing loaded)
    if (type != [d integerForKey:@"selectedPasswordType"] || self.passwordView.subviews.count == 0) {
        [d setInteger:type forKey:@"selectedPasswordType"];
        PasswordTypesViewController *vc = [self.password getViewControllerForPasswordType:type];
        self.currentPasswordTypeViewController = vc;
        self.passwordView.subviews = @[];

        [self.passwordView addSubview:vc.view];
        
        //set constraints so that the PasswordTypes view fills the passwordView
        NSDictionary *views = @{@"ptvc":vc.view};
        [vc.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSArray *h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ptvc]|" options:0 metrics:nil views:views];
        NSArray *v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ptvc]|" options:0 metrics:nil views:views];
        [self.passwordView addConstraints:h];
        [self.passwordView addConstraints:v];

        [self generatePassword];
    }
    if(self.passwordTypeLabel) {
        [self.passwordTypeLabel setStringValue:[[self.password getNameForPasswordType:type] uppercaseString]];
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
    c.imageView.image = [TypeIcons getTypeIcon:type];
    return c;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = self.passwordTypesTable.selectedRow;
    [self changeSelectionTypeByIndex:row];

}
@end
