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
    
    self.phoneticSoundsTwo = @[@"BA",@"BE",@"BO",@"BU",@"BY",@"DA",@"DE",@"DI",@"DO",@"DU",@"FA",@"FE",@"FI",@"FO",@"FU",@"GA",@"GE",@"GI",@"GO",@"GU",@"HA",@"HE",@"HI",@"HO",@"HU",@"JA",@"JE",@"JI",@"JO",@"JU",@"KA",@"KE",@"KI",@"KO",@"KU",@"LA",@"LE",@"LI",@"LO",@"LU",@"MA",@"ME",@"MI",@"MO",@"MU",@"NA",@"NE",@"NI",@"NO",@"NU",@"PA",@"PE",@"PI",@"PO",@"PU",@"RA",@"RE",@"RI",@"RO",@"RU",@"SA",@"SE",@"SI",@"SO",@"SU",@"TA",@"TE",@"TI",@"TO",@"TU",@"VA",@"VE",@"VI",@"VO",@"VU"];
    self.phoneticSoundsThree = @[@"BRA",@"BRE",@"BRI",@"BRO",@"BRU",@"BRY",@"DRA",@"DRE",@"DRI",@"DRO",@"DRU",@"DRY",@"FRA",@"FRE",@"FRI",@"FRO",@"FRU",@"FRY",@"GRA",@"GRE",@"GRI",@"GRO",@"GRU",@"GRY",@"PRA",@"PRE",@"PRI",@"PRO",@"PRU",@"PRY",@"STA",@"STE",@"STI",@"STO",@"STU",@"STY",@"TRA",@"TRE"];
    self.phoneticSounds = [self.phoneticSoundsTwo arrayByAddingObjectsFromArray:self.phoneticSoundsThree];

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
                      @(PFRandomType): @"Random",
                      @(PFPatternType): @"Pattern",
                      @(PFPassphraseType): @"Passphrase",
                      @(PFPronounceableType): @"Pronounceable",
                      @(PFAdvancedType): @"Advanced",
                      @(PFStoredType): @"Stored"
                      };
    self.caseTypes = @{
                       @(PFLowerCase): @"Lowercase",
                       @(PFUpperCase): @"Uppercase",
                       @(PFMixedCase): @"Mixed Case",
                       @(PFTitleCase): @"Title Case"
                       };
    self.separatorTypes = @{
                            @(PFNoSeparator) : @"None",
                            @(PFHyphenSeparator) : @"Hyphen",
                            @(PFSpaceSeparator) : @"Space",
                            @(PFUnderscoreSeparator) : @"Underscore",
                            @(PFNumberSeparator) : @"Number",
                            @(PFSymbolSeparator) : @"Symbol",
                            @(PFCharacterSeparator) : @"Character",
                            @(PFEmojiSeparator) : @"Emoji",
                            @(PFRandomSeparator) : @"Random",
                            
                            };
    self.patternBase = @{
                        @(PFNumberType): @[@"#",@"Number"],
                        @(PFLowerCaseWordType): @[@"w",@"Lowercase Word"],
                        @(PFUpperCaseWordType): @[@"W",@"Uppercase Word"],
                        @(PFRandomCaseWordType): @[@"d",@"Random Case Word"],
                        @(PFTitleCaseWordType): @[@"D",@"Title Case Word"],
                        @(PFLowerCaseShortWordType): @[@"s",@"Lowercase Short Word"],
                        @(PFUpperCaseShortWordType): @[@"S",@"Uppercase Short Word"],
                        @(PFRandomCaseShortWordType): @[@"h",@"Random Case Short Word"],
                        @(PFTitleCaseShortWordType): @[@"H",@"Title Case Short Word"],
                        @(PFSymbolType): @[@"!",@"Symbol"],
                        @(PFLowerCaseCharacterType): @[@"c",@"Lowercase Character"],
                        @(PFUpperCaseCharacterType): @[@"C",@"Uppercase Character"],
                        @(PFNonAmbiguousCharacterType): @[@"a",@"Non-Ambiguous Lowercase Character"],
                        @(PFNonAmbiguousUpperCaseCharacterType): @[@"A",@"Non-Ambiguous Uppercase Character"],
                        @(PFNonAmbiguousNumberType): @[@"N",@"Non-Ambiguous Number"],
                        @(PFLowerCasePhoneticSoundType): @[@"p",@"Lowercase Phonetic Sound"],
                        @(PFUpperCasePhoneticSoundType): @[@"P",@"Uppercase Phonetic Sound"],
                        @(PFRandomCasePhoneticSoundType): @[@"t",@"Random Case Phonetic Sound"],
                        @(PFTitleCasePhoneticSoundType): @[@"T",@"Title Case Phonetic Sound"],
                        @(PFEmojiType): @[@"e",@"Emoji"],
                        @(PFRandomItemType): @[@"r",@"Random Item"]
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
                              @"cloudKitSynced"];
}

/**
 Builds out indexes for use in getting types by order as well as building out pattern dictionaries
 */
-(void)buildIndexes {
    //get indexes
    self.passwordTypesIndex = [[self.passwordTypes allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.caseTypeIndex = [[self.caseTypes allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.separatorTypeIndex = [[self.separatorTypes allKeys] sortedArrayUsingSelector:@selector(compare:)];
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
    self.patternTypeToDescription = pd;
    self.patternCharacterToType = pc;
    self.patternTypeToName = pn;
    self.patternTypeToCharacter = pt;
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
