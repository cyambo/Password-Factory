//
//  TodayViewController.m
//  Password Factory Widget
//
//  Created by Cristiana Yambo on 8/17/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "PasswordFactory.h"
#import "DefaultsManager.h"
#import "BBPasswordStrength.h"
@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, strong) PasswordFactory *factory;
@end

@implementation TodayViewController

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    self.factory = [[PasswordFactory alloc] init];

    [self generatePassword];
    completionHandler(NCUpdateResultNoData);
}

- (IBAction)generatePassword:(id)sender {
    [self generatePassword];
}

- (IBAction)copyPassword:(id)sender {
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
    //TODO: use shared defautls for type
    NSString *type = @"Random";
    NSUserDefaults *sd = [DefaultsManager sharedDefaults];
    self.factory.passwordLength = [[sd objectForKey:@"passwordLengthShared"] floatValue];
    self.factory.useSymbols = [[sd objectForKey:@"randomUseSymbolsShared"] boolValue];
    self.factory.mixedCase = [[sd objectForKey:@"randomMixedCaseShared"] boolValue];
    self.factory.avoidAmbiguous = [[sd objectForKey:@"randomAvoidAmbiguousShared"] boolValue];
    NSString *password;
    if ([type isEqualToString:@"Random"]) {
        password = [self.factory generateRandom];
    } else if ([type isEqualToString:@"Pattern"]) {
        password = [self.factory generatePattern:[sd objectForKey:@"userPatternShared"]];
        
    } else {
        password = [self.factory generatePronounceable:[sd objectForKey:@"pronounceableSeparatorShared"]];
    }
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

