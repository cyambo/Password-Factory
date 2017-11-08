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
    
    self.characterPattern = @{@"#" : @1,  //Number
                         @"w" : @2,  //Lowercase Word
                         @"W" : @3,  //Uppercase word
                         @"s" : @4,  //lowercase short word
                         @"S" : @5,  //uppercase short word
                         @"!" : @6,  //symbol
                         @"c" : @7,  //random character
                         @"C" : @8,  //random uppercase char
                         @"a" : @9,  //random non-ambiguous char
                         @"A" : @10, //random non-ambiguous uppercase char
                         @"N" : @11, //random non-ambiguous number
                         @"e" : @12, //random emoji
                         @"p" : @13, //random phonetic sound
                         @"P" : @14, //random uppercase phonetic sound
                         @"r" : @15  //random item generated from random tab settings
                         };
    self.characterPatternNames = @{@"#" : @"Number",
                              @"w" : @"Lowercase Word",
                              @"W" : @"Uppercase Word",
                              @"s" : @"Lowercase Short Word",
                              @"S" : @"Uppercase Short Word",
                              @"!" : @"Symbol",
                              @"c" : @"Lowercase Character",
                              @"C" : @"Uppercase Character",
                              @"a" : @"Non-Ambiguous Lowercase Character",
                              @"A" : @"Non-Ambiguous Uppercase Character",
                              @"N" : @"Non-Ambiguous Number",
                              @"e" : @"Emoji",
                              @"p" : @"Phonetic Sound",
                              @"P" : @"Uppercase Phonetic Sound",
                              @"r" : @"Random Item"
                              };
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
                      @(PFPronounceableType): @"Pronounceable"
                      };
    
}
@end
