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
}

- (IBAction)changePasswordType:(id)sender {
    [self generatePassword];
}

-(void)generatePassword {
    NSString *type = [(NSButtonCell *)self.passwordType.selectedCell title];
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
//    [self.strengthBox updateStrength:.2];
    [self.passwordField setStringValue:password];
 }
@end

