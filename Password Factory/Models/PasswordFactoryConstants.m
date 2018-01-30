//
//  PasswordFactoryConstants.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordFactoryConstants.h"
@interface PasswordFactoryConstants ()

@property (nonatomic, strong) NSDictionary *constants;
@property (nonatomic, strong) NSDictionary *patternBase;
@property (nonatomic, strong) NSDictionary *separatorBase;

@end

@implementation PasswordFactoryConstants
+ (instancetype)get {
    static dispatch_once_t once = 0;
    static PasswordFactoryConstants *singleton = nil;
    
    dispatch_once(&once, ^ {
        singleton = [[PasswordFactoryConstants alloc] init];
    });
    
    return singleton;
}
- (instancetype)init {
    self = [super init];
    [self setConstants];
    [self buildIndexes];
    return self;
}
- (void)setConstants {
    self.symbols = @"!@#$%^&*(){}[];:.\"<>?/\\-_+=|\'";

    self.upperCase = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    self.lowerCase = @"abcdefghijklmnopqrstuvwxyz";
    self.nonAmbiguousUpperCase = @"ABCDEFGHJKLMNPQRSTUVWXYZ";
    self.nonAmbiguousLowerCase = @"abcdefghijkmnpqrstuvwxyz";
    self.numbers = @"0123456789";
    self.nonAmbiguousNumbers = @"23456789";
    

    self.passwordCharacterTypes = @{
                               @(PFSymbols): self.symbols,
                               @(PFUpperCaseLetters): self.upperCase,
                               @(PFLowerCaseLetters): self.lowerCase,
                               @(PFNonAmbiguousUpperCaseLetters): self.nonAmbiguousUpperCase,
                               @(PFNonAmbiguousLowerCaseLetters): self.nonAmbiguousLowerCase,
                               @(PFNumbers): self.numbers,
                               @(PFNonAmbiguousNumbers): self.nonAmbiguousNumbers,
                               };
    self.passwordTypes = @{
                           @(PFRandomType): NSLocalizedString(@"randomTypeName", comment: @"Random"),
                           @(PFPatternType): NSLocalizedString(@"patternTypeName", comment: @"Pattern"),
                           @(PFPassphraseType): NSLocalizedString(@"passphraseTypeName", comment: @"Passphrase"),
                           @(PFPronounceableType): NSLocalizedString(@"pronounceableTypeName", comment: @"Pronounceable"),
                           @(PFAdvancedType): NSLocalizedString(@"advancedTypeName", comment: @"Advanced"),
                           @(PFStoredType): NSLocalizedString(@"storedTypeName", comment: @"Stored")
                           };
    
    self.caseTypes = @{
                       @(PFLowerCase): NSLocalizedString(@"lowerCaseName", comment: @"Lowercase"),
                       @(PFUpperCase): NSLocalizedString(@"upperCaseName", comment: @"Uppercase"),
                       @(PFMixedCase): NSLocalizedString(@"mixedCaseName", comment: @"Mixed Case"),
                       @(PFTitleCase): NSLocalizedString(@"titleCaseName", comment: @"Title Case")
                       };
    
    self.separatorBase = @{
                            @(PFNoSeparator) : @[NSLocalizedString(@"noneSeparatorTypeName", comment: @"None"), @""],
                            @(PFHyphenSeparator) : @[NSLocalizedString(@"hyphenSeparatorTypeName", comment: @"Hyphen"), @"-"],
                            @(PFSpaceSeparator) : @[NSLocalizedString(@"spaceSeparatorTypeName", comment: @"Space"), @" "],
                            @(PFUnderscoreSeparator) : @[NSLocalizedString(@"underscoreSeparatorTypeName", comment: @"Underscore"),@"_"],
                            @(PFPeriodSeparator) : @[NSLocalizedString(@"periodSeparatorTypeName", comment: @"Period"),@"."],
                            @(PFNumberSeparator) : @[NSLocalizedString(@"numberSeparatorTypeName", comment: @"Number")],
                            @(PFSymbolSeparator) : @[NSLocalizedString(@"symbolSeparatorTypeName", comment: @"Symbol")],
                            @(PFCharacterSeparator) : @[NSLocalizedString(@"characterSeparatorTypeName", comment: @"Character")],
                            @(PFEmojiSeparator) : @[NSLocalizedString(@"emojiSeparatorTypeName", comment: @"Emoji")],
                            @(PFRandomSeparator) : @[NSLocalizedString(@"randomSeparatorTypeName", comment: @"Random")]
                            
                            };
    self.patternBase = @{
                         @(PFNumberType): @[@"#",NSLocalizedString(@"numberPatternName", comment: @"Number")],
                         @(PFLowerCaseWordType): @[@"w",NSLocalizedString(@"lowercaseWordPatternName", comment: @"Lowercase Word")],
                         @(PFUpperCaseWordType): @[@"W",NSLocalizedString(@"uppercaseWordPatternName", comment: @"Uppercase Word")],
                         @(PFRandomCaseWordType): @[@"d",NSLocalizedString(@"randomCaseWordPatternName", comment: @"Random Case Word")],
                         @(PFTitleCaseWordType): @[@"D",NSLocalizedString(@"titleCaseWordPatternName", comment: @"Title Case Word")],
                         @(PFLowerCaseShortWordType): @[@"s",NSLocalizedString(@"lowercaseShortWordPatternName", comment: @"Lowercase Short Word")],
                         @(PFUpperCaseShortWordType): @[@"S",NSLocalizedString(@"uppercaseShortWordPatternName", comment: @"Uppercase Short Word")],
                         @(PFRandomCaseShortWordType): @[@"h",NSLocalizedString(@"randomCaseShortWordPatternName", comment: @"Random Case Short Word")],
                         @(PFTitleCaseShortWordType): @[@"H",NSLocalizedString(@"titleCaseShortWordPatternName", comment: @"Title Case Short Word")],
                         @(PFSymbolType): @[@"!",NSLocalizedString(@"symbolPatternName", comment: @"Symbol")],
                         @(PFLowerCaseCharacterType): @[@"c",NSLocalizedString(@"lowerCaseCharacterPatternName", comment: @"Lowercase Character")],
                         @(PFUpperCaseCharacterType): @[@"C",NSLocalizedString(@"upperCaseCharacterPatternName", comment: @"Uppercase Character")],
                         @(PFNonAmbiguousCharacterType): @[@"a",NSLocalizedString(@"nonAmbiguousLowercaseCharacterPatternName", comment: @"Non-Ambiguous Lowercase Character")],
                         @(PFNonAmbiguousUpperCaseCharacterType): @[@"A",NSLocalizedString(@"nonAmbiguousUppercaseCharacterPatternName", comment: @"Non-Ambiguous Uppercase Character")],
                         @(PFNonAmbiguousNumberType): @[@"N",NSLocalizedString(@"nonAmbiguousNumberPatternName", comment: @"Non-Ambiguous Number")],
                         @(PFLowerCasePhoneticSoundType): @[@"p",NSLocalizedString(@"lowerCasePhoneticSoundPatternName", comment: @"Lowercase Phonetic Sound")],
                         @(PFUpperCasePhoneticSoundType): @[@"P",NSLocalizedString(@"upperCasePhoneticSoundPatternName", comment: @"Uppercase Phonetic Sound")],
                         @(PFRandomCasePhoneticSoundType): @[@"t",NSLocalizedString(@"randomCasePhoneticSoundPatternName", comment: @"Random Case Phonetic Sound")],
                         @(PFTitleCasePhoneticSoundType): @[@"T",NSLocalizedString(@"titleCasePhoneticSoundPatternName", comment: @"Title Case Phonetic Sound")],
                         @(PFEmojiType): @[@"e",NSLocalizedString(@"emojiPatternName", comment: @"Emoji")],
                         @(PFRandomItemType): @[@"r",NSLocalizedString(@"randomItemPatternName", comment: @"Random Item")]
                         };
    
    NSMutableString *e = [[NSMutableString alloc] init];
    for(int i = 0; i < self.symbols.length; i++) {
        [e appendString:[NSString stringWithFormat:@"\\%c",[self.symbols characterAtIndex:i]]];
    }
    self.escapedSymbols = e;
    self.disabledSyncKeys = @[@"enableRemoteStore",
                              @"selectedPasswordType",
                              @"storePasswords",
                              @"activeControl",
                              @"iCloudIsAvailable",
                              @"cloudKitChangeToken",
                              @"storedPasswordTableSelectedRow",
                              @"isMenuApp",
                              @"hideDockIcon",
                              @"addToLoginItems",
                              @"cloudKitCurrentZoneStartTime"];
}

/**
 Builds out indexes for use in getting types by order as well as building out pattern dictionaries
 */
-(void)buildIndexes {
    //get indexes
    self.passwordTypesIndex = [[self.passwordTypes allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.caseTypeIndex = [[self.caseTypes allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.separatorTypeIndex = [[self.separatorBase allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.patternTypeIndex = [[self.patternBase allKeys] sortedArrayUsingSelector:@selector(compare:)];
    //building type name dictionary
    NSArray *tk = self.passwordTypes.allKeys;
    NSArray *tv = [self.passwordTypes objectsForKeys:tk notFoundMarker:[NSNull null]];
    self.passwordNameToType = [NSDictionary dictionaryWithObjects:tk forKeys:tv];
    //build out pattern dictionaries
    NSMutableDictionary *pc = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *pn = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *pt = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *pd = [[NSMutableDictionary alloc] init];
    for(NSNumber *key in self.patternBase) {
        NSString *c = self.patternBase[key][0];
        NSString *name = self.patternBase[key][1];
        pc[c] = key;
        pn[key] = [NSString stringWithFormat:@"%@ - %@",c,name];
        pt[key] = [NSString stringWithFormat:@"%@",c];
        pd[key] = name;
        
    }
    self.patternTypeToDescription = [pd copy];
    self.patternCharacterToType = [pc copy];
    self.patternTypeToName = [pn copy];
    self.patternTypeToCharacter = [pt copy];
    
    NSMutableDictionary *st = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sv = [[NSMutableDictionary alloc] init];
    //build out the separator types dictionaries
    for(NSNumber *key in self.separatorBase) {
        NSArray *val = self.separatorBase[key];
        st[key] = val[0];
        if (val.count == 2) {
            sv[key] = val[1];
        }
    }
    self.separatorTypeValues = [sv copy];
    self.separatorTypes = [st copy];
}
-(PFCaseType)getCaseTypeByIndex:(NSUInteger)index {
    return (PFCaseType)[(NSNumber *)self.caseTypeIndex[index] integerValue];
}
-(PFSeparatorType)getSeparatorTypeByIndex:(NSUInteger)index {
    return (PFSeparatorType)[(NSNumber *)self.separatorTypeIndex[index] integerValue];
}
-(PFPatternTypeItem)getPatternTypeByIndex:(NSUInteger)index {
    return (PFPatternTypeItem)[(NSNumber *)self.patternTypeIndex[index] integerValue];
}
-(PFPasswordType)getPasswordTypeByIndex:(NSUInteger)index {
    return (PFPasswordType)[(NSNumber *)self.passwordTypesIndex[index] integerValue];
}
/**
 Gets name of password type for PFPasswordType
 
 @param type PFPasswordType
 @return String of name
 */
-(NSString *)getNameForPasswordType:(PFPasswordType)type {
    return self.passwordTypes[@(type)];
}

-(NSString *)getNameForCaseType:(PFCaseType)type {
    return self.caseTypes[@(type)];
}
-(NSString *)getNameForSeparatorType:(PFSeparatorType)type {
    return self.separatorTypes[@(type)];
}
-(NSString *)getNameForPatternTypeItem:(PFPatternTypeItem)type {
    return self.patternTypeToName[@(type)];
}
@end
