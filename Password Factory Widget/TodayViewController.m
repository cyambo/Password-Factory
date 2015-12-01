//
//  TodayViewController.m
//  Password Factory Widget
//
//  Created by Cristiana Yambo on 8/17/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//
#import "constants.h"
#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "PasswordFactory.h"
#import "DefaultsManager.h"
#import "BBPasswordStrength.h"

@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, strong) PasswordFactory *factory;
@property (nonatomic, strong) id clearClipboardTimer;
@end

@implementation TodayViewController

- (void)viewWillAppear {
    if(!self.factory) {
        self.factory = [[PasswordFactory alloc] init];
    }
    [self changeLabel];

    [self generatePassword];
}
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

- (IBAction)generatePassword:(id)sender {
    [self generatePassword];
}

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
    //closing window if it is a menuApp
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMenuApp"]) {
        NSWindow *window = [[NSApplication sharedApplication] mainWindow];
        if (window.isVisible) {
            [window close];
        }
    }
}
- (void)changeLabel {
    NSUserDefaults *sd = [DefaultsManager sharedDefaults];
    int index = (int)[[sd objectForKey:@"selectedTabIndexShared"] integerValue];
    
    
    NSString *label;

    switch(index) {
        case PFTabRandom:
            label = @"Random";
            break;
        case PFTabPattern:
            label = @"Pattern";
            break;
        case PFTabPronounceable:
            label = @"Pronounceable";
            break;
        case PFTabPassphrase:
            label = @"Passphrase";
            break;
            
    }
    [self.passwordType setStringValue:label];
}
- (void)clearClipboard {
    [self updatePasteboard:@""];
}
- (void)updatePasteboard:(NSString *)val {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    NSArray *toPasteboard = @[val];
    BOOL ok = [pasteboard writeObjects:toPasteboard];
    if (!ok) { NSLog(@"Write to pasteboard failed");}
}
- (IBAction)backToApp:(id)sender {
    NSURL *u = [[NSURL alloc] initWithString:@"c13PasswordFactory://"];
    [self.extensionContext openURL:u completionHandler:^(BOOL success) {
        NSLog(@"C");
    }];

}

- (IBAction)changePasswordType:(id)sender {
    [self generatePassword];
}

-(void)generatePassword {
    
    if(!self.factory) {
        self.factory = [[PasswordFactory alloc] init];
    }
    NSUserDefaults *sd = [DefaultsManager sharedDefaults];

    
    int index = (int)[[sd objectForKey:@"selectedTabIndexShared"] integerValue];
    NSString *password;
    
 
    self.factory.passwordLength = [[sd objectForKey:@"passwordLengthShared"] integerValue];
    
    
    BOOL useSymbols = [[sd objectForKey:@"randomUseSymbolsShared"] boolValue];
    BOOL mixedCase = [[sd objectForKey:@"randomMixedCaseShared"] boolValue];
    BOOL avoidAmbiguous = [[sd objectForKey:@"randomAvoidAmbiguousShared"] boolValue];
    
    //TODO: still working on this
    switch(index) {
        case PFTabRandom:
           
            password = [self.factory generateRandom:mixedCase avoidAmbiguous:avoidAmbiguous useSymbols:useSymbols];
            break;
        case PFTabPattern:
            password = [self.factory generatePattern:[sd objectForKey:@"userPatternShared"]];
            break;
        case PFTabPronounceable:
 
            password = [self.factory generatePronounceableWithSeparatorType:(int)[sd integerForKey:@"pronounceableSeparatorTagShared"]];
            break;
        case PFTabPassphrase:
            password = [self.factory generatePassphraseWithCode:(int)[sd integerForKey:@"passphraseSeparatorTagShared"] caseType:(int)[sd integerForKey:@"passphraseCaseTypeTagShared"]];

            break;
    }
    [self changeLabel];
    [self updateStrength:password];
    [self.passwordField setStringValue:password];
 }
-(void)updateStrength:(NSString *)password {
    BBPasswordStrength *strength = [[BBPasswordStrength alloc] initWithPassword:password];
    NSString *type = [(NSButtonCell *)self.passwordType.selectedCell title];
    //playing around with numbers to make a good scale
    double ct = log10(strength.crackTime);
    //tweaking output based on password type
    if ([type isEqualToString:@"Random"]) {
        ct = (ct/40)*100;
    } else if ([type isEqualToString:@"Pattern"]) {
        ct = (ct/20)*100;
        
    } else {
        ct = (ct/40)*100;
    }

    
    
    if (ct > 100) {ct = 100;}
    [self.strengthBox updateStrength:ct];
}
@end

