//
//  constants.h
//  Password Factory
//
//  Created by Cristiana Yambo on 8/20/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef Password_Factory_constants_h
#define Password_Factory_constants_h

typedef NS_ENUM(NSInteger, PFCaseType) {
    PFLower = 101,
    PFUpper,
    PFMixed,
    PFTitle
};
typedef NS_ENUM(NSInteger,PFSeparatorType) {
    PFNoSeparator = 201,
    PFHyphenSeparator,
    PFSpaceSeparator,
    PFUnderscoreSeparator,
    PFNumberSeparator,
    PFSymbolSeparator,
    PFCharacterSeparator,
    PFEmojiSeparator,
    PFRandomSeparator
};
typedef NS_ENUM(NSInteger, PFCharacterType) {
    PFUpperCaseLetters = 301,
    PFLowerCaseLetters,
    PFNumbers,
    PFSymbols,
    PFNonAmbiguousUpperCaseLetters,
    PFNonAmbiguousLowerCaseLetters,
    PFNonAmbiguousNumbers,
    PFAllCharacters
};

typedef NS_ENUM(NSInteger, PFPasswordType) {
    PFRandomType = 401,
    PFPatternType,
    PFPronounceableType,
    PFPassphraseType,
    PFAdvancedType
};

#define PFPasswordMinLength 5
#define PFPasswordMaxLength 150

#define PFPasswordNumEmojiInRandom 10

#define GenerateAndCopyLoops 20

extern NSString * const SupportEmailAddress;
extern NSString * const SharedDefaultsAppGroup;
extern NSString * const NotificationSoundName;
extern NSString * const HelperIdentifier;
extern NSString * const OpenSettingsURL;

extern NSString * const EnglishWordsArchiveFilename;
extern NSString * const ShortWordsArchiveFilename;
extern NSString * const WordsByLengthWordsArchiveFilename;
extern NSString * const EmojiArchiveFilename;
#endif

