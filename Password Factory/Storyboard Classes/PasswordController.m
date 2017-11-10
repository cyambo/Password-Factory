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

/**
 Gets the password controller singleton

 @return PasswordController instance
 */
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
 Generate password based on type and settings from view controller

 @param type PFPasswordType
 */
- (void)generatePassword:(PFPasswordType)type {
    NSDictionary *settings = [[self getViewControllerForPasswordType:type] getPasswordSettings];
    [self generatePassword:type withSettings:settings];

}

/**
 Generates password

 @param type PFPasswordType
 @param settings dictionary containing password generation settings
 */
- (void)generatePassword:(PFPasswordType)type withSettings:(NSDictionary *)settings {
    if(settings[@"passwordLength"]) {
        self.factory.length = [(NSNumber *)settings[@"passwordLength"] integerValue];
    }
    if(settings[@"useSymbols"]) {
        self.factory.useSymbols = [(NSNumber *)settings[@"useSymbols"] boolValue];
    }
    if(settings[@"avoidAmbiguous"]) {
        self.factory.avoidAmbiguous = [(NSNumber *)settings[@"avoidAmbiguous"] boolValue];
    }
    if(settings[@"useEmoji"]) {
        self.factory.useEmoji = [(NSNumber *)settings[@"useEmoji"] boolValue];
    }
    if(settings[@"useNumbers"]) {
        self.factory.useNumbers = [(NSNumber *)settings[@"useNumbers"] boolValue];
    }
    self.password = @"";
    switch (type) {
        case PFRandomType: //random
            if (settings[@"caseType"]) {
                self.factory.caseType = (PFCaseType)[(NSNumber *)settings[@"caseType"] integerValue];
            } else {
                self.factory.caseType = PFLower;
            }
            self.password = [self.factory generateRandom];
            break;
        case PFPatternType: //pattern
            self.password = [self.factory generatePattern:settings[@"patternText"]];
            break;
            
        case PFPronounceableType: //pronounceable
            self.factory.caseType = (PFCaseType)[(NSNumber *)settings[@"caseType"] integerValue];
            self.password = [self.factory generatePronounceableWithSeparatorType:(PFSeparatorType)[(NSNumber *)settings[@"separatorType"] integerValue]];
            break;
        case PFPassphraseType: //passphrase:
            self.factory.caseType = (PFCaseType)[(NSNumber *)settings[@"caseType"] integerValue];
            self.password = [self.factory generatePassphraseWithSeparatorType:(PFSeparatorType)[(NSNumber *)settings[@"separatorType"] integerValue]];
            break;
    }
    [self updatePasswordStrength];
    if (self.delegate) {
        [self.delegate passwordChanged:self.password];
    }
}

/**
 Initialize the PasswordTypesViewControllers for all the types
 */
- (void)initViewControllers {
    if (self.viewControllers == nil) {
        NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        NSDictionary *types = [self.factory getAllPasswordTypes];
        NSMutableDictionary *vcs = [[NSMutableDictionary alloc] init];
        for(NSNumber *key in types) {
            NSString *name = types[key];
            NSString *storyboardName = [NSString stringWithFormat:@"%@Password",name];
            PasswordTypesViewController *vc = [storyBoard instantiateControllerWithIdentifier:storyboardName];
            vc.passwordType = (PFPasswordType)[key integerValue];
            vc.delegate = self;
            vcs[key] = vc;
        }
        self.viewControllers = vcs;
    }
}

/**
 Gets the viewController for PFPasswordType

 @param type PFPasswordType
 @return ViewController matching type
 */
- (PasswordTypesViewController *)getViewControllerForPasswordType:(PFPasswordType)type {
    [self initViewControllers];
    return self.viewControllers[@(type)];
}

/**
 PasswordTypesViewControllerDelegate method, called when a control has changed in the PasswordTypesViewController instances

 @param type PFPasswordType changed
 @param settings settings from viewController where control was changed
 */
-(void)controlChanged:(PFPasswordType)type settings:(NSDictionary *)settings {
    [self generatePassword:type withSettings:settings];
}
/**
 Updates the password strength meter and the crack time string
 */
- (void)updatePasswordStrength {
    [self.passwordStrength updatePasswordStrength:self.password withCrackTimeString:self.generateCrackTimeString];
}
- (void)enableOptionalPasswordTypes:(BOOL)advanced storePasswords:(BOOL)stored {
    self.factory.enableAdvanced = advanced;
    self.factory.enabledStored = stored;
    
}
-(void)setPasswordValue:(NSString *)password {
    self.password = password;
}
-(NSString *)getPasswordValue {
    return self.password;
}
-(float)getPasswordStrength {
    return self.passwordStrength.strength;
}
-(NSString *)getCrackTimeString {
    return self.passwordStrength.crackTimeString;
}
#pragma mark PasswordFactory methods
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
- (NSDictionary *)getFilteredPasswordTypes {
    return [self.factory getFilteredPasswordTypes];
}
@end
