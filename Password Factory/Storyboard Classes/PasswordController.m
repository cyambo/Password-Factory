//
//  PasswordController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordController.h"
#import "PasswordStrength.h"
#import "PasswordTypesViewController.h"

@interface PasswordController()
@property (nonatomic, strong) PasswordStrength *passwordStrength;
@property (nonatomic, strong) PasswordFactory *factory;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSDictionary *viewControllers;
@end

@implementation PasswordController
+ (instancetype)get {
    static dispatch_once_t once = 0;
    static PasswordController *singleton = nil;
    
    dispatch_once(&once, ^ {
        singleton = [[PasswordController alloc] init];
        singleton.passwordStrength = [[PasswordStrength alloc] init];
        singleton.factory = [[PasswordFactory alloc] init];
        singleton.password = @"";
    });
    
    return singleton;
}
/**
 Generates password in the proper format
 */
- (void)generatePassword:(PFPasswordType)type {
    //Generates different password formats based upon the selected tab
    NSDictionary *settings = [[self getViewControllerForPasswordType:type] getPasswordSettings];
    if(settings[@"length"]) {
        self.factory.length = (NSUInteger)settings[@"length"];
    }
    self.password = @"";
    switch (type) {
        case PFRandomType: //random
            if (settings[@"caseType"]) {
                self.factory.caseType = (PFCaseType)settings[@"caseType"];
            } else {
                self.factory.caseType = PFLower;
            }
            self.password = [self.factory generateRandom];
            break;
        case PFPatternType: //pattern
            self.password = [self.factory generatePattern:settings[@"patternText"]];
            break;

        case PFPronounceableType: //pronounceable
            self.factory.caseType = (PFCaseType)settings[@"caseType"];
            self.password = [self.factory generatePronounceableWithSeparatorType:(PFSeparatorType)settings[@"separatorType"]];
            break;
        case PFPassphraseType: //passphrase:
            self.factory.caseType = (PFCaseType)settings[@"caseType"];
            self.password = [self.factory generatePassphraseWithSeparatorType:(PFSeparatorType)settings[@"separatorType"]];
            break;
    }
    [self updatePasswordStrength];
}
- (void)initViewControllers {
    if (self.viewControllers == nil) {
        NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        NSDictionary *types = self.factory.getAllPasswordTypes;
        NSMutableDictionary *vcs = [[NSMutableDictionary alloc] init];
        for(NSNumber *key in types) {
            NSString *name = types[key];
            NSString *storyboardName = [NSString stringWithFormat:@"%@Password",name];
            PasswordTypesViewController *vc = [storyBoard instantiateControllerWithIdentifier:storyboardName];
            vc.passwordType = (PFPasswordType)[key integerValue];
            vcs[key] = vc;
        }
        self.viewControllers = vcs;
    }
}
- (PasswordTypesViewController *)getViewControllerForPasswordType:(PFPasswordType)type {
    [self initViewControllers];
    return self.viewControllers[@(type)];
}
/**
 Updates the password strength meter and the crack time string
 */
- (void)updatePasswordStrength {
    [self.passwordStrength updatePasswordStrength:self.password withCrackTimeString:self.generateCrackTimeString];
}
-(void)setPasswordValue:(NSString *)password {
    self.password = password;
}
-(NSString *)getPasswordValue {
    return self.password;
}
-(int)getPasswordStrength {
    return self.passwordStrength.strength;
}
-(NSString *)getCrackTimeString {
    return self.passwordStrength.crackTimeString;
}
- (BOOL)isCharacterType:(PFCharacterType)type character:(NSString *)character {
    return [self.factory isCharacterType:type character:character];
}
- (NSString *)getNameForPasswordType: (PFPasswordType)type {
    return [self.factory getNameForPasswordType:type];
}
- (NSDictionary *)getAllPasswordTypes {
    return [self.factory getAllPasswordTypes];
    
}
- (PFPasswordType)getPasswordTypeByIndex:(NSInteger)index {
    return [self.factory getPasswordTypeByIndex:index];
}
- (NSUInteger)getIndexByPasswordType:(PFPasswordType)type {
    return [self.factory getIndexByPasswordType:type];
}
@end
