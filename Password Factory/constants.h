//
//  constants.h
//  Password Factory
//
//  Created by Cristiana Yambo on 8/20/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//
#import <Foundation/Foundation.h>
#if TARGET_OS_OSX
#define IS_MACOS 1
#else
#define IS_IOS 1
#endif
#ifndef Password_Factory_constants_h
#define Password_Factory_constants_h

typedef NS_ENUM(NSInteger, PFCaseType) {
    PFLowerCase = 101,
    PFUpperCase,
    PFMixedCase,
    PFTitleCase
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
    PFAdvancedType,
    PFStoredType
};
typedef NS_ENUM(NSInteger, PFPatternTypeItem) {
    PFNumberType = 501,
    PFLowerCaseWordType,
    PFUpperCaseWordType,
    PFRandomCaseWordType,
    PFTitleCaseWordType,
    PFLowerCaseShortWordType,
    PFUpperCaseShortWordType,
    PFRandomCaseShortWordType,
    PFTitleCaseShortWordType,
    PFSymbolType,
    PFLowerCaseCharacterType,
    PFUpperCaseCharacterType,
    PFNonAmbiguousCharacterType,
    PFNonAmbiguousUpperCaseCharacterType,
    PFNonAmbiguousNumberType,
    PFLowerCasePhoneticSoundType,
    PFUpperCasePhoneticSoundType,
    PFRandomCasePhoneticSoundType,
    PFTitleCasePhoneticSoundType,
    PFEmojiType,
    PFRandomItemType
};

typedef NS_ENUM(NSInteger, PFErrorCode) {
    PFCoreDataLoadError = 9901,
    PFCoreDataDeleteOverMaxFetchError,
    PFCoreDataSaveFailedError,
    PFCoreDataLoadSavedDataFailedError,
    PFCoreDataDeleteAllFailedError,
    PFPasteboardFailError
};
#define PFPasswordMinLength 5
#define PFPasswordMaxLength 150

#define PFPasswordNumEmojiInRandom 10

#define GenerateAndCopyLoops 20

#define PFZoomSmallFontSize 32
#define PFZoomMediumFontSize 48
#define PFZoomLargeFontSize 72
#define PFZoomXLargeFontSize 128

#define PFObserverTimeThreshold 80000000

extern NSString * const SupportEmailAddress;
extern NSString * const SharedDefaultsAppGroup;
extern NSString * const iCloudContainer;
extern NSString * const iCloudContainerZone;
extern NSString * const NotificationSoundName;
extern NSString * const HelperIdentifier;
extern NSString * const AppIdentifier;
extern NSString * const OpenSettingsURL;
extern NSString * const ZoomPasswordURL;

extern NSString * const EnglishWordsArchiveFilename;
extern NSString * const ShortWordsArchiveFilename;
extern NSString * const WordsByLengthWordsArchiveFilename;
extern NSString * const EmojiArchiveFilename;
extern NSString * const ZoomFontName;

extern NSString * const ExtendedCharacterWarning;
extern NSString * const StartAtLoginNotInApplicationsWarning;
extern NSString * const StoredPasswordOffWarning;
extern NSString * const StoredPasswordOnWarning;
extern NSString * const ResetToDefaultsWarning;
extern NSString * const ResetToDefaultsWarningiOS;
extern NSString * const ResetAllDialogsWarning;
extern NSString * const PasswordSaveError;
extern NSString * const MenuRestartMessage;
extern NSString * const remoteStoreChangeWarning;
extern NSString * const enableRemoteStoreWarning;
extern NSString * const disableRemoteStoreWarning;
extern NSString * const eraseRemoteStoreWarning;
#endif

