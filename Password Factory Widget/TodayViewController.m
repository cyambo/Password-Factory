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
#import "PasswordFactory.h"
#import "DefaultsManager.h"
#import "PasswordStrength.h"


/**
 Displays a today widget showing a simplified app
 Uses the shared defaults system to get data and configuration from the main app
 */
@interface TodayViewController () <NCWidgetProviding>

@property (nonatomic, strong) PasswordFactory *factory;
@property (nonatomic, strong) id clearClipboardTimer;
@property (nonatomic, strong) PasswordStrength *passwordStrength;

@end

@implementation TodayViewController

/**
 Initialize the model and update interface
 */
- (void)viewWillAppear {
    if(!self.factory) {
        self.factory = [[PasswordFactory alloc] init];
    }
    [self changeLabel];
    [self generatePassword];
}

/**
 Change the label when the view changes
 */
-(void)viewDidLayout {
    [self changeLabel];
}
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you

    [self generatePassword];
    completionHandler(NCUpdateResultNoData);
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
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [self updatePasteboard:[self.passwordField stringValue]];
    if ([d boolForKey:@"clearClipboardShared"]) {
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
}

/**
 Changes the label showing which type of password is being generated
 */
- (void)changeLabel {
    NSUserDefaults *sd = [DefaultsManager sharedDefaults];
    PFPasswordType index = (PFPasswordType)[[sd objectForKey:@"selectedTabIndexShared"] integerValue];
    
    NSString *label;

    switch(index) {
        case PFRandomType:
            label = @"Random:";
            break;
        case PFPatternType:
            label = @"Pattern:";
            break;
        case PFPronounceableType:
            label = @"Pronounceable:";
            break;
        case PFPassphraseType:
            label = @"Passphrase:";
            break;
    }
    [self.passwordType setStringValue:label];
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
- (IBAction)changePasswordType:(id)sender {
    [self generatePassword];
}

/**
 Generate a password based upon the main app's settings
 */
-(void)generatePassword {
    
    if(!self.factory) {
        self.factory = [[PasswordFactory alloc] init];
    }
    NSUserDefaults *sd = [DefaultsManager sharedDefaults];

    int index = (int)[[sd objectForKey:@"selectedTabIndexShared"] integerValue];
    NSString *password;
    
    self.factory.length = [[sd objectForKey:@"passwordLengthShared"] integerValue];
    
    self.factory.useSymbols = [[sd objectForKey:@"randomUseSymbolsShared"] boolValue];
    if ([[sd objectForKey:@"randomMixedCaseShared"] boolValue]) {
        self.factory.caseType = PFMixed;
    } else {
        self.factory.caseType = PFLower;
    }
    self.factory.avoidAmbiguous = [[sd objectForKey:@"randomAvoidAmbiguousShared"] boolValue];
    
    //TODO: not getting all values for caseType etc from defaults
    
    switch(index) {
        case PFRandomType:
            password = [self.factory generateRandom];
            break;
        case PFPatternType:
            password = [self.factory generatePattern:[sd objectForKey:@"userPatternShared"]];
            break;
        case PFPronounceableType:
            password = [self.factory generatePronounceableWithSeparatorType:(PFSeparatorType)[sd integerForKey:@"pronounceableSeparatorTagShared"]];
            break;
        case PFPassphraseType:
            password = [self.factory generatePassphraseWithSeparatorType:(PFSeparatorType)[sd integerForKey:@"passphraseSeparatorTagShared"]];

            break;
    }
    [self changeLabel];
    [self updateStrength:password index:index];
    [self.passwordField setStringValue:password];
 }

/**
 Updates the color of the strength box depending on the password strength

 @param password password to check
 @param index selected tab index to change the strength type based upon what type of password is generated
 */
-(void)updateStrength:(NSString *)password index:(int)index {
    if (!self.passwordStrength) {
        self.passwordStrength = [[PasswordStrength alloc] init];
    }
    [self.passwordStrength updatePasswordStrength:password withCrackTimeString:NO];
    [self.strengthBox updateStrength:self.passwordStrength.strength];
}
@end

