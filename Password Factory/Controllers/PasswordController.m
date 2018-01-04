//
//  PasswordController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordController.h"
#import "PasswordStrength.h"
#import "PasswordFactoryConstants.h"
#import "DefaultsManager.h"
#import "PasswordStorage.h"
@interface PasswordController()
@property (nonatomic, strong) PasswordStrength *passwordStrength;
@property (nonatomic, strong) PasswordFactory *factory;
@property (nonatomic, strong) NSDictionary *viewControllers;
@property (nonatomic, strong) PasswordFactoryConstants *c;
@property (nonatomic, strong) PasswordStorage *storage;
@property (nonatomic, strong) DefaultsManager *defaults;
@end

@implementation PasswordController

/**
 Gets the password controller singleton

 @return PasswordController instance
 */
+ (instancetype)get:(BOOL)useShared {
    static dispatch_once_t once = 0;
    static PasswordController *singleton = nil;
    
    dispatch_once(&once, ^ {
        singleton = [[PasswordController alloc] initWithShared:useShared];

    });

    return singleton;
}
-(instancetype)initWithShared:(BOOL)useShared {
    self = [super init];
    self.defaults = [DefaultsManager get];
    [self.defaults enableShared:useShared];
    
    self.passwordStrength = [[PasswordStrength alloc] init];
    self.factory = [PasswordFactory get];
    self.c = [PasswordFactoryConstants get];
    self.storage = [PasswordStorage get];
    
    self.password = @"";
    return self;
}
/**
 Generate password based on type and settings from view controller

 @param type PFPasswordType
 */
- (void)generatePassword:(PFPasswordType)type {
    
    if (type != PFStoredType) {
        NSDictionary *settings = [self getPasswordSettingsByType:type];
        [self generatePassword:type withSettings:settings];
    } else {
#ifdef IS_MACOS
        PasswordTypesViewController *vc = [self getViewControllerForPasswordType:type];
        [vc selectRandomFromStored];
#else
        NSDictionary *settings = [self getPasswordSettingsByType:type];
        [self generatePassword:type withSettings:settings];
#endif
    }
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
    NSString *currPassword = @"";
    switch (type) {
        case PFRandomType: //random
            if (settings[@"caseType"]) {
                self.factory.caseType = (PFCaseType)[(NSNumber *)settings[@"caseType"] integerValue];
            } else {
                self.factory.caseType = PFLowerCase;
            }
            currPassword = [self.factory generateRandom];
            break;
        case PFPatternType: //pattern
            currPassword = [self.factory generatePattern:settings[@"patternText"]];
            break;
            
        case PFPronounceableType: //pronounceable
            self.factory.caseType = (PFCaseType)[(NSNumber *)settings[@"caseType"] integerValue];
            currPassword = [self.factory generatePronounceableWithSeparatorType:(PFSeparatorType)[(NSNumber *)settings[@"separatorType"] integerValue]];
            break;
        case PFPassphraseType: //passphrase:
            self.factory.caseType = (PFCaseType)[(NSNumber *)settings[@"caseType"] integerValue];
            currPassword = [self.factory generatePassphraseWithSeparatorType:(PFSeparatorType)[(NSNumber *)settings[@"separatorType"] integerValue]];
            break;
        case PFAdvancedType:
            self.factory.caseType = 0;
            if (settings[@"caseType"]) {
                self.factory.caseType = (PFCaseType)[(NSNumber *)settings[@"caseType"] integerValue];
            }
            self.factory.prefix = @"";
            self.factory.suffix = @"";
            if (settings[@"prefix"]) {
                self.factory.prefix = settings[@"prefix"];
            }
            if (settings[@"suffix"]) {
                self.factory.suffix = settings[@"suffix"];
            }
            if(settings[@"findRegex"]) {
                self.factory.find = settings[@"findRegex"];
                self.factory.replace = settings[@"replacePattern"];
            } else {
                self.factory.find = nil;
            }
            self.factory.replaceAmbiguous = [settings[@"replaceAmbiguous"] boolValue];
            self.factory.truncate = [settings[@"truncateAt"] integerValue];
            currPassword = [self.factory transformPassword:settings[@"generatedPassword"] symbolCasePrecent:[settings[@"symbolCasePercent"] integerValue] accentedCasePercent:[settings[@"accentedCasePercent"] integerValue]];
            break;
        case PFStoredType:
            currPassword = settings[@"storedPassword"];
            break;
    }
    self.password = currPassword;
    [self updatePasswordStrength];
    if (self.delegate && !settings[@"noDisplay"]) {
        [self.delegate passwordChanged:self.password];
    }
    return self.password;
}

/**
 Initialize the PasswordTypesViewControllers for all the types
 */
#ifdef IS_MACOS
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
            vc.prefix = [[self getNameForPasswordType:vc.passwordType] lowercaseString];
            vc.delegate = self;
            vcs[key] = vc;
        }
        self.viewControllers = vcs;
    }
}
#endif
/**
 Gets the viewController for PFPasswordType

 @param type PFPasswordType
 @return ViewController matching type
 */
#ifdef IS_MACOS
- (PasswordTypesViewController *)getViewControllerForPasswordType:(PFPasswordType)type {
    [self initViewControllers];
    return self.viewControllers[@(type)];
}
#endif
/**
 PasswordTypesViewControllerDelegate method, called when a control has changed in the PasswordTypesViewController instances

 @param type PFPasswordType changed
 */
-(void)controlChanged:(PFPasswordType)type{
    NSDictionary *settings = [self getPasswordSettingsByType:type];
    [self generatePassword:type withSettings:settings];
}
/**
 Updates the password strength meter and the crack time string
 */
- (void)updatePasswordStrength {
    NSString *curr = @"";
    if (self.password != nil) {
        curr = self.password;
    }
    [self.passwordStrength updatePasswordStrength:curr withCrackTimeString:self.generateCrackTimeString];
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
    NSString * cts = self.passwordStrength.crackTimeString;
    if (!cts.length) {
        [self updatePasswordStrength];
    }
    cts = self.passwordStrength.crackTimeString;
    if (cts != nil) {
        return cts;
    }
    return @"";
}
-(NSString *)getCrackTimeString:(NSString *)password {
    self.password = password;
    self.passwordStrength.crackTimeString = @"";
    self.generateCrackTimeString = YES;
    return [self getCrackTimeString];
    
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

- (NSDictionary *)getPasswordSettingsByType:(PFPasswordType)type {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //Generates different password formats based upon the selected tab
    //set modifiers
    DefaultsManager *d = self.defaults;
    
    settings[@"avoidAmbiguous"] = @([d boolForKey:@"randomAvoidAmbiguous"]);
    settings[@"useSymbols"] = @([d boolForKey:@"randomUseSymbols"]);
    settings[@"useEmoji"] = @([d boolForKey:@"randomUseEmoji"]);
    settings[@"useNumbers"] = @([d boolForKey:@"randomUseNumbers"]);
    settings[@"passwordLength"] = @([self getPasswordLength]);
    
    switch (type) {
        case PFRandomType: //random
            settings[@"caseType"] = @([self getCaseTypeForType:type]);
            break;
        case PFPatternType: //pattern
            settings[@"patternText"] = [d stringForKey:@"userPattern"];
            break;
        case PFPronounceableType: //pronounceable
            settings[@"caseType"] = @([self getCaseTypeForType:type]);
            settings[@"separatorType"] = @([self getSeparatorTypeForType:type]);
        case PFPassphraseType: //passphrase:
            settings[@"caseType"] = @([self getCaseTypeForType:type]);
            settings[@"separatorType"] = @([self getSeparatorTypeForType:type]);
            break;
        case PFAdvancedType: //advanced
            [settings addEntriesFromDictionary:[self generateAdvancedPasswordSettings]];
            break;
        case PFStoredType: //stored

            if ([self.storage count] && [d integerForKey:@"storedPasswordTableSelectedRow"] >=0) {
                settings[@"storedPassword"] = [self.storage passwordAtIndex:[d integerForKey:@"storedPasswordTableSelectedRow"]].password;
            } else {
                settings[@"storedPassword"] = @"";
            }
    
    }
    return settings;
}
/**
 Generates the advanced password settings for password generation
 
 @return settings dictionary
 */
-(NSMutableDictionary *)generateAdvancedPasswordSettings {
    PFPasswordType sourceType;
    DefaultsManager *d = self.defaults;
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    sourceType = (PFPasswordType)([d integerForKey:@"advancedSourceIndex"] + PFRandomType);
    //changing the prefix to the source type so that we get the proper settings
    NSMutableDictionary *sourceSettings = [[self getPasswordSettingsByType:sourceType] mutableCopy];
    sourceSettings[@"noDisplay"] = @(YES);
    NSString *password = [self generatePassword:sourceType withSettings:sourceSettings];
    
    settings[@"generatedPassword"] = password;
    settings[@"truncateAt"] = @([d integerForKey:@"advancedTruncateAt"]);
    
    //generating the prefix and the suffix
    NSString *pre = [d stringForKey:@"advancedPrefixPattern"];
    NSString *post = [d stringForKey:@"advancedSuffixPattern"];
    if (pre.length || post.length) {
        NSMutableDictionary *patternSettings = [[self getPasswordSettingsByType:PFPatternType] mutableCopy];
        patternSettings[@"noDisplay"] = @(YES);
        if(pre.length) {
            patternSettings[@"patternText"] = pre;
            settings[@"prefix"] = [self generatePassword:PFPatternType withSettings:patternSettings];
        }
        if(post.length) {
            patternSettings[@"patternText"] = post;
            settings[@"suffix"] = [self generatePassword:PFPatternType withSettings:patternSettings];
        }
    }
    
    settings[@"accentedCasePercent"] = @([d integerForKey:@"advancedAccentedCasePercent"]);
    settings[@"symbolCasePercent"] = @([d integerForKey:@"advancedSymbolCasePercent"]);
    settings[@"replaceAmbiguous"] = @([d boolForKey:@"advancedReplaceAmbiguous"]);
    //set the case type
    NSUInteger caseTypeIndex = [d integerForKey:@"advancedCaseTypeIndex"];
    
    if(caseTypeIndex != 0) { //no change has a tag of zero
        settings[@"caseType"] = @((caseTypeIndex + PFLowerCase -1));
    }
    NSString *find = [d stringForKey:@"advancedFindRegex"];
    if( find  && find.length) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:find options:0 error:&error];
        if (!error) {
            settings[@"findRegex"] = regex;
            settings[@"replacePattern"] = [d stringForKey:@"advancedReplacePattern"];
        }
    }
    return settings;
}
/**
 Gets the set password length
 
 @return password length
 */
-(NSUInteger)getPasswordLength {
    return [self.defaults integerForKey:@"passwordLength"];
}

-(NSUInteger)getTruncateLength {
    return [self.defaults integerForKey:@"advancedTruncateAt"];
}
/**
 Gets the case type for the selected password type
 
 @return PFCaseType
 */
-(PFCaseType)getCaseTypeForType:(PFPasswordType)type {
    DefaultsManager *d = self.defaults;
    NSString *typeName = [[self getNameForPasswordType:type] lowercaseString];
    NSString *name = [NSString stringWithFormat:@"%@CaseTypeIndex",typeName];
    NSUInteger index = [d integerForKey:name];
    return [self.c getCaseTypeByIndex:index];
}

/**
 Gets the separator type for the selected password type
 
 @return PFSeparatorType
 */
-(PFSeparatorType)getSeparatorTypeForType:(PFPasswordType)type {
    DefaultsManager *d = self.defaults;
    NSString *typeName = [[self getNameForPasswordType:type] lowercaseString];
    NSString *name = [NSString stringWithFormat:@"%@SeparatorTypeIndex",typeName];
    NSUInteger index = [d integerForKey:name];
    return [self.c getSeparatorTypeByIndex:index];
    
}
@end
