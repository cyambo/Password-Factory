//
//  TodayViewController.m
//  Password Factory Widget
//
//  Created by Cristiana Yambo on 8/17/15.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//
#import "constants.h"
#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "DefaultsManager.h"
#import "PasswordStrength.h"
#import "PasswordFactoryConstants.h"
#import "PasswordController.h"
#import "PasswordStorage.h"
#import "Utilities.h"
/**
 Displays a today widget showing a simplified app
 Uses the shared defaults system to get data and configuration from the main app
 */
@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) id clearClipboardTimer;
@property (nonatomic, strong) PasswordStrength *passwordStrength;
@property (nonatomic, strong) PasswordController *passwordController;
@property (nonatomic, strong) DefaultsManager *d;
@property (nonatomic, strong) PasswordStorage *storage;

@end

@implementation TodayViewController
- (instancetype)init {
    self = [super init];
    DefaultsManager.useSharedDataSource = YES;
    PasswordStorage.disableRemoteFetchChanges = YES;
    [Utilities setRemoteStore];
    self.d = [DefaultsManager get];
    
    self.passwordController = [PasswordController get];
    self.passwordStrength = [[PasswordStrength alloc] init];
    self.storage = [PasswordStorage get];
    
    return self;
}
/**
 Initialize the model and update interface
 */
- (void)viewWillAppear {
    self.strengthMeter.wantsLayer = YES;
    self.strengthMeter.layer.backgroundColor = [[NSColor colorWithWhite:0.73 alpha:0.1] CGColor];
    self.strengthMeter.layer.cornerRadius = 10.0;
    [self generatePassword];
}

/**
 Change the label when the view changes
 */
-(void)viewDidLayout {
    [self setupTypesPopup];
}
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you

    [self generatePassword];
    completionHandler(NCUpdateResultNoData);
}

/**
 Fills the types popup with the activated types
 */
-(void)setupTypesPopup {
    self.passwordController.useStoredType = [self.d boolForKey:@"storePasswords"];
    self.passwordController.useAdvancedType = [self.d boolForKey:@"enableAdvanced"];
    [self.passwordType removeAllItems];
    NSDictionary *types = [self.passwordController getFilteredPasswordTypes];
    int i = 0;
    for(NSNumber *t in [[types allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        PFPasswordType type = (PFPasswordType)[t integerValue];
        if (type != PFStoredType) {
            NSString *name = types[t];
            [self.passwordType addItemWithTitle:name];
            [self.passwordType itemAtIndex:i].tag = type;
            i++;
        }
    }
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSInteger sel = [d integerForKey:@"widgetSelectedPasswordType"];
    //check to see if we are off the end, that means the password type changed
    //and that one does not exist anymore
    if (sel >= self.passwordType.numberOfItems) {
        sel = 0;
    }
    [self.passwordType selectItemAtIndex:sel];
}
/**
 Pressed the 'generate' button

 @param sender default sender
 */
- (IBAction)generatePassword:(id)sender {
    [self generatePassword];
}

/**
 Pressed the 'copy' button

 @param sender default sender
 */
- (IBAction)copyPassword:(id)sender {
    [self updatePasteboard:[self.passwordField stringValue]];
    if ([self.d boolForKey:@"clearClipboard"]) {
        //setting up clear clipboard timer
        if ([self.clearClipboardTimer isValid]) {
            [self.clearClipboardTimer invalidate];
        }
        self.clearClipboardTimer =
        [NSTimer scheduledTimerWithTimeInterval:[self.d integerForKey:@"clearClipboardTime"]
                                         target:self
                                       selector:@selector(clearClipboard)
                                       userInfo:nil
                                        repeats:NO];
        
    }
}


/**
 Clear the clipboard
 */
- (void)clearClipboard {
    [self updatePasteboard:@""];
}

/**
 Updates the clipboard with specified value

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
 Pressed the gear button to open up the main application

 @param sender default sender
 */
- (IBAction)backToApp:(id)sender {
    NSURL *u = [[NSURL alloc] initWithString:OpenSettingsURL];
    [[NSWorkspace sharedWorkspace] openURL:u];
}


/**
 Generate a new password when the type has changed

 @param sender default sender
 */
- (IBAction)changePasswordType:(NSPopUpButton *)sender {
    [self generatePassword];
}

/**
 Generate a password based upon the main app's settings
 */
-(void)generatePassword {
    PFPasswordType type = (PFPasswordType)self.passwordType.selectedTag;
    if (type > 0) {
        [self.passwordController generatePassword:type];
        
        [self updateStrength:self.passwordController.password];
        NSInteger currentFontSize = [(NSNumber *)[[self.passwordField font].fontDescriptor objectForKey:NSFontSizeAttribute] integerValue];
        NSAttributedString *s = [Utilities colorText:self.passwordController.password size:currentFontSize];
        [self.passwordField setAttributedStringValue:s];
    }
    [self storePassword];

 }

/**
 Stores password in database
 */
-(void)storePassword {
    if ([self.d boolForKey:@"storePasswords"]) {
        PFPasswordType currType = (PFPasswordType)self.passwordType.selectedTag;
        //don't store anything if we are on the stored type
        if (currType != PFStoredType) {
            [self.storage storePassword:self.passwordController.password strength:self.passwordStrength.strength type:currType];

        }
    }
}
/**
 Called when the zoom password button is pressed, will display the ZoomWindow
 
 @param sender default sender
 */
- (IBAction)zoomPassword:(id)sender {
    NSString *escapedString = [self.passwordController.password stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    escapedString = [NSString stringWithFormat:@"?password=%@",escapedString];
    NSString *urlString = [ZoomPasswordURL stringByAppendingString:escapedString];
    NSURL *u = [[NSURL alloc] initWithString:urlString];
    [[NSWorkspace sharedWorkspace] openURL:u];
}
/**
 Updates the color of the strength box depending on the password strength

 @param password password to check

 */
-(void)updateStrength:(NSString *)password {
    [self.passwordStrength updatePasswordStrength:password withCrackTimeString:NO];
    [self.strengthMeter updateStrength:self.passwordStrength.strength];
}

@end

