//
//  PasswordTypesViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordTypesViewController.h"
#import "PasswordController.h"
@interface PasswordTypesViewController () <NSTextFieldDelegate>
@property (nonatomic, strong) NSDictionary *caseTypeRadios;
@property (nonatomic, strong) NSDictionary *separatorTypeRadios;
@property (nonatomic, assign) NSUInteger passwordLength;
@property (nonatomic, strong) NSString *prefix;
- (PFSeparatorType)getSeparatorType;
- (PFCaseType)getCaseType;
@end

@implementation PasswordTypesViewController

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.passwordLength = 0;
    return self;
}
-(void)viewWillAppear {
    self.caseTypeRadios = @{
                            @(PFUpper): [self testRadio:self.caseTypeUpperCase],
                            @(PFLower): [self testRadio:self.caseTypeLowerCase],
                            @(PFMixed): [self testRadio:self.caseTypeMixedCase],
                            @(PFTitle): [self testRadio:self.caseTypeTitleCase]
                            };
    self.separatorTypeRadios = @{
                                 @(PFNoSeparator): [self testRadio:self.noSeparator],
                                 @(PFHyphenSeparator): [self testRadio:self.hyphenSeparator],
                                 @(PFSpaceSeparator): [self testRadio:self.spaceSeparator],
                                 @(PFUnderscoreSeparator): [self testRadio:self.underscoreSeparator],
                                 @(PFNumberSeparator): [self testRadio:self.numberSeparator],
                                 @(PFSymbolSeparator): [self testRadio:self.symbolSeparator],
                                 @(PFCharacterSeparator): [self testRadio:self.characterSeparator],
                                 @(PFEmojiSeparator): [self testRadio:self.emojiSeparator],
                                 @(PFRandomSeparator): [self testRadio:self.randomSeparator]
                                 };
    self.prefix = @"";
    if([self.delegate isKindOfClass:[PasswordController class]]) {
        self.prefix = [[(PasswordController *)self.delegate getNameForPasswordType:self.passwordType] lowercaseString];
    }
    [self setupRadios];
    [self changeLength:nil];
    
}
-(void)setupRadios {
    //setting up caseType
    if(self.passwordType == PFRandomType || self.passwordType == PFPronounceableType || self.passwordType == PFPassphraseType) {
        NSString *defaultsName = [NSString stringWithFormat:@"%@CaseType", self.prefix];
        PFCaseType caseType = [[NSUserDefaults standardUserDefaults] integerForKey:defaultsName];
        for(NSNumber *key in self.caseTypeRadios) {
            if([self.caseTypeRadios[key] isKindOfClass:[NSButton class]]) {
                NSButton *button = (NSButton *)self.caseTypeRadios[key];
                if((PFCaseType)[key integerValue] == caseType) {
                    [button setState:NSControlStateValueOn];
                } else {
                    [button setState:NSControlStateValueOff];
                }
            }
        }
    }
    //setting up separator type
    if(self.passwordType == PFPronounceableType || self.passwordType == PFPassphraseType) {
        NSString *defaultsName = [NSString stringWithFormat:@"%@SeparatorType", self.prefix];
        PFSeparatorType sepType = [[NSUserDefaults standardUserDefaults] integerForKey:defaultsName];
        for(NSNumber *key in self.separatorTypeRadios) {
            if([self.separatorTypeRadios[key] isKindOfClass:[NSButton class]]) {
                NSButton *button = (NSButton *)self.separatorTypeRadios[key];
                if((PFSeparatorType)[key integerValue] == sepType) {
                    [button setState:NSControlStateValueOn];
                } else {
                    [button setState:NSControlStateValueOff];
                }
            }
        }
    }
}
-(id)testRadio:(NSButton *)toTest {
    if (toTest == nil) {
        return [NSNull null];
    } else {
        return toTest;
    }
}
-(NSDictionary *)getPasswordSettings {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //Generates different password formats based upon the selected tab
    //set modifiers
    if ([self.avoidAmbiguous isKindOfClass:[NSButton class]]) {
        settings[@"avoidAmbiguous"] = @([self.avoidAmbiguous state]);
    }
    if ([self.useSymbols isKindOfClass:[NSButton class]]) {
        settings[@"useSymbols"] = @([self.useSymbols state]);
    }
    if ([self.useEmoji isKindOfClass:[NSButton class]]) {
        settings[@"useEmoji"] = @([self.useEmoji state]);
    }
    if ([self.useNumbers isKindOfClass:[NSButton class]]) {
        settings[@"useNumbers"] = @([self.useNumbers state]);
    }
    settings[@"passwordLength"] = @([self getPasswordLength]);
    switch (self.passwordType) {
        case PFRandomType: //random
            settings[@"caseType"] = @([self getCaseType]);
            break;
        case PFPatternType: //pattern
            settings[@"patternText"] = self.patternText.stringValue;
            break;
        case PFPronounceableType: //pronounceable
            settings[@"caseType"] = @([self getCaseType]);
            settings[@"separatorType"] = @([self getSeparatorType]);
            break;
        case PFPassphraseType: //passphrase:
            settings[@"caseType"] = @([self getCaseType]);
            settings[@"separatorType"] = @([self getSeparatorType]);
            break;
    }
    return settings;
}
-(NSUInteger)getPasswordLength {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"passwordLength"];
}
-(PFCaseType)getCaseType {
    for(NSNumber *key in self.caseTypeRadios) {
        if([self.caseTypeRadios[key] isKindOfClass:[NSButton class]]) {
            NSButton *radio = (NSButton*)self.caseTypeRadios[key];
            if(radio.state == NSOnState) {
                return (PFCaseType)[key integerValue];
            }
        }
    }
    return PFLower;
}
-(PFSeparatorType)getSeparatorType {
    for(NSNumber *key in self.separatorTypeRadios) {
        if([self.separatorTypeRadios[key] isKindOfClass:[NSButton class]]) {
            NSButton *radio = (NSButton*)self.separatorTypeRadios[key];
            if(radio.state == NSOnState) {
                return (PFSeparatorType)[key integerValue];
            }
        }
    }
    return PFHyphenSeparator;
}

- (IBAction)changeLength:(id)sender {
    if ([self getPasswordLength] != self.passwordLength) {
        self.passwordLength = [self getPasswordLength];
        [self.passwordLengthText setStringValue:[NSString stringWithFormat:@"%lu",self.passwordLength]];
        [self callDelegate];
    }
    
}
- (IBAction)changeOptions:(id)sender {
    [self callDelegate];
}
- (IBAction)changeSeparatorType:(id)sender {
    NSString *defaultsName = [NSString stringWithFormat:@"%@SeparatorType", self.prefix];
    PFSeparatorType type = [self getSeparatorType];
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:defaultsName];
    [self callDelegate];
}
- (IBAction)changeCaseType:(id)sender {
    NSString *defaultsName = [NSString stringWithFormat:@"%@CaseType", self.prefix];
    PFCaseType type = [self getCaseType];
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:defaultsName];
    [self callDelegate];
}
- (void)controlTextDidChange:(NSNotification *)obj {
    [self callDelegate];
}
-(void)callDelegate {
    if(self.delegate) {
        [self.delegate controlChanged:self.passwordType settings:[self getPasswordSettings]];
    }
}




/**
 Gets the passphrase separator type and adds the type to the shared defaults
 
 @return separator type
 */
//- (PFSeparatorType)getPassphraseSeparatorType {
//    PFSeparatorType type = (PFSeparatorType)[(NSButtonCell *)[self.passphraseSeparatorRadio selectedCell] tag];
//    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"passphraseSeparatorTagShared"];
//    return type;
//}

/**
 Gets the passphrase case type and adds it to the shared defaults
 
 @return case type
 */
//- (PFCaseType)getPassphraseCaseType {
//    int type = (int)[(NSButtonCell *)[self.passphraseCaseRadio selectedCell] tag];
//    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"passphraseCaseTypeTagShared"];
//    return type;
//}

/**
 Gets the pronounceable separator type and adds it to the shared defaults
 
 @return separator type
 */
//- (PFSeparatorType)getPronounceableSeparatorType {
//    PFSeparatorType type = (PFSeparatorType)[(NSButtonCell *)[self.pronounceableSeparatorRadio selectedCell] tag];
//    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"pronounceableSeparatorTagShared"];
//    return  type;
//
//}
@end
