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
#import "PasswordFactoryConstants.h"
@interface PasswordController()
@property (nonatomic, strong) PasswordStrength *passwordStrength;
@property (nonatomic, strong) PasswordFactory *factory;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSDictionary *viewControllers;
@property (nonatomic, strong) PasswordFactoryConstants *c;
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
        singleton.factory = [PasswordFactory get];
        singleton.c = [PasswordFactoryConstants get];
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

/**
 Generates password

 @param type PFPasswordType
 @param settings settings dictionary containing password generation settings
 @return generated password
 */
- (NSString *)generatePassword:(PFPasswordType)type withSettings:(NSDictionary *)settings {
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
                self.factory.caseType = PFLowerCase;
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
        case PFAdvancedType:
            self.factory.caseType = 0;
            if (settings[@"caseType"]) {
                self.factory.caseType = (PFCaseType)[(NSNumber *)settings[@"caseType"] integerValue];
            }
            if (settings[@"prefix"]) {
                self.factory.prefix = settings[@"prefix"];
            }
            if (settings[@"postfix"]) {
                self.factory.postfix = settings[@"postfix"];
            }

            self.factory.replaceAmbiguous = [settings[@"replaceAmbiguous"] boolValue];
            self.factory.truncate = [settings[@"truncateAt"] integerValue];
            self.password = [self.factory transformPassword:settings[@"generatedPassword"] symbolCasePrecent:[settings[@"symbolCasePercent"] integerValue] accentedCasePercent:[settings[@"accentedCasePercent"] integerValue]];
            break;
    }
    [self updatePasswordStrength];
    if (self.delegate) {
        [self.delegate passwordChanged:self.password];
    }
    return self.password;
}

/**
 Initialize the PasswordTypesViewControllers for all the types
 */
- (void)initViewControllers {
    if (self.viewControllers == nil) {
        NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        NSDictionary *types = self.c.passwordTypes;
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
    return [self.c getNameForPasswordType:type];
}
- (NSDictionary *)getAllPasswordTypes {
    return self.c.passwordTypes;
}


/**
 Gets the password type by index (0, 1, etc) whih sorts by the PFPasswordType value
 
 @param index Index - 0, 1, 2 etc
 @return PFPasswordType matching index
 */
-(PFPasswordType)getPasswordTypeByIndex:(NSUInteger)index {
    
    NSArray *keys = [[[self getFilteredPasswordTypes] allKeys] sortedArrayUsingSelector:@selector(compare:)]; //get sorted keys
    if (index < keys.count) {
        return (PFPasswordType)[(NSNumber *)keys[index] integerValue];
    }
    return PFRandomType;
}
/**
 Gets the index of the particular passsword type
 
 @param type PFPasswordType
 @return integer index
 */
-(NSUInteger)getIndexByPasswordType:(PFPasswordType)type {
    NSArray *keys = [[[self getFilteredPasswordTypes] allKeys] sortedArrayUsingSelector:@selector(compare:)]; //get sorted keys
    for(int i = 0; i < keys.count; i++) {
        if ((PFPasswordType)[(NSNumber *)keys[i] integerValue] == type) {
            return i;
        }
    }
    return 0;
}

/**
 Returns the password types dictionary with Advanced or Stored filtered out because they are optional
 
 @return dictionary of password types
 */
- (NSDictionary *)getFilteredPasswordTypes {
    NSMutableDictionary *types = [self.c.passwordTypes mutableCopy];
    if (!self.useAdvancedType) {
        [types removeObjectForKey:@(PFAdvancedType)];
    }
    if (!self.useStoredType) {
        [types removeObjectForKey:@(PFStoredType)];
    }
    return types;
}


@end
