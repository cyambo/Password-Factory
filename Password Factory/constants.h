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


#define PFPassphraseUseLowerCase 101
#define PFPassphraseUseUpperCase 102
#define PFPassphraseUseMixedCase 103
#define PFPassphraseUseTitleCase 104


#define PFPronounceableHyphenSeparator 201
#define PFPronounceableNumberSeparator 202
#define PFPronounceableNoSeparator 203
#define PFPronounceableSymbolSeparator 204
#define PFPronounceableCharacterSeparator 205
#define PFPronounceableSpaceSeparator 206


#define PFPassphraseHyphenSeparator 301
#define PFPassphraseSpaceSeparator 302
#define PFPassphraseUnderscoreSeparator 303
#define PFPassphraseNoSeparator 304

#define PFPassphraseLowerCase 401
#define PFPassphraseTitleCase 402
#define PFPassphraseUpperCase 403
#define PFPassphraseMixedCase 404

#define PFTabRandom 0
#define PFTabPattern 1
#define PFTabPronounceable 2
#define PFTabPassphrase 3

#define PFPasswordMinLength 5
#define PFPasswordMaxLength 150

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

