//
//  PasswordFactory.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordFactory.h"
#import "PasswordFactoryConstants.h"
#import "NSString+RandomCase.h"
#import "NSString+SymbolCase.h"
#import "NSString+AccentedCase.h"
#import "NSString+ReplaceAmbiguous.h"
#import "SecureRandom.h"
#import "NSString+UnicodeLength.h"

#ifdef IS_MACOS
#import "AppDelegate.h"
#endif
@interface PasswordFactory ()

@property (nonatomic, strong) NSString *separator;
@property (nonatomic, strong) NSMutableArray *currentRange;
@property (nonatomic, strong) NSArray *englishWords;
@property (nonatomic, strong) NSArray *shortWords;
@property (nonatomic, strong) NSDictionary *wordsByLength;
@property (nonatomic, strong) NSArray *emojis;
@property (nonatomic, strong) NSArray *badWords;
@property (nonatomic, strong) NSArray *phoneticSoundsTwo;
@property (nonatomic, strong) NSArray *phoneticSoundsThree;
@property (nonatomic, strong) NSArray *phoneticSounds;
@property (nonatomic, strong) PasswordFactoryConstants *c;
@end

@implementation PasswordFactory

/**
 Singleton Get Method
 
 @return PaswordFactory
 */
+ (instancetype)get {
    static dispatch_once_t once = 0;
    static PasswordFactory *singleton = nil;
    
    dispatch_once(&once, ^ {
        singleton = [[PasswordFactory alloc] init];
        
    });
    
    return singleton;
    
}
- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [self loadWords];
        self.c = [PasswordFactoryConstants get];
        self.length = 5;
        self.prefix = @"";
        self.suffix = @"";
    }
    return self;
}

#pragma mark Pronounceable Password


/**
 *  Generates a pronounceable password using the separator property
 *
 *  @return pronounceable password approximately the legnth of the length property
 */
- (NSString *)generatePronounceable {
    NSMutableString *p = [[NSMutableString alloc] init];
    
    int i = 0;
    
    while ([p getUnicodeLength] < self.length) {
        NSString *append = [self caseString:[self getPronounceableForLength:(self.length - [p getUnicodeLength])]];
        if ([append isEqual: @""]) {
            break;
        } else {
            if ([p getUnicodeLength]) {
                [p appendString:self.separator];
            }
            [p appendString:append];
        }
        
        i++;
    }
    return p;
}
/**
 *  Generates a 'pronounceable' password
 *
 *  @param separatorType string of separator type, can be hyphen, numbers, none, symbols, characters, spaces
 *
 *  @return pronounceable password with separator and approximately .length property
 */
- (NSString *)generatePronounceableWithSeparatorType:(PFSeparatorType)separatorType {
    
    [self setSeparatorFromType:separatorType];
    
    return [self generatePronounceable];
}
#pragma mark Pronounceable Utilities
/**
 *  with pronounceable we don't want to exceed the set password length, so choose the appropriate size 'sound'
 *
 *  @param length remaining length left in password string
 *
 *  @return a pronounceable 'piece'
 */
- (NSString *)getPronounceableForLength:(NSUInteger)length {
    if (length < 2) { //if we have a length less than two, return nothing
        return @"";
    }
    else if (length == 2) { //return a two length sound
        return [self randomFromArray:self.phoneticSoundsTwo];
    } else if (length == 3) { //return a three length sound
        return [self randomFromArray:self.phoneticSoundsThree];
    }
    else { //return any length sound
        NSUInteger numSyllables = [SecureRandom randomInt:3] + 1;
        NSMutableString *sound = [[NSMutableString alloc] init];
        for(int i = 0; i <= numSyllables; i++) {
            [sound appendString:[self randomFromArray:self.phoneticSounds]];
            if ((length - sound.length) < 3) {
                break;
            }
        }
        return sound;
    }
    return @"";
}
/**
 *  Sets separator based on type string
 *
 *  @param separatorType is a code from constants.h
 *
 */
- (void)setSeparatorFromType:(PFSeparatorType)separatorType {
    NSString *sep = @"";
    if (self.c.separatorTypeValues[@(separatorType)] != nil) {
        sep = self.c.separatorTypeValues[@(separatorType)];
    }
    switch (separatorType) {
        case PFNumberSeparator:
            sep = [NSString stringWithFormat:@"%d",[SecureRandom randomInt:10]];
            break;
        case PFSymbolSeparator:
            sep = [self randomFromString:self.c.symbols];
            break;
        case PFCharacterSeparator:
            sep = [self randomFromString:self.c.nonAmbiguousUpperCase];
            break;
        case PFEmojiSeparator:
            sep = [self.emojis objectAtIndex:[SecureRandom randomInt:[SecureRandom randomInt:(uint)self.emojis.count]]];
            break;
        case PFRandomSeparator:
            sep = [self generateRandomWithLength:1];
            break;
        default:
            break;
    }
    self.separator = sep;
}
#pragma mark Passphrase
/**
 *  Generates a passphrase by combining various length words
 *
 *  @return password based on passphrase settings and approximately the length property
 */
-(NSString *)generatePassphrase {
    NSString *separator = self.separator;
    NSMutableString *p = [[NSMutableString alloc] init];
    while ([p getUnicodeLength] < self.length) {
        NSString *append = [self caseString:[self getPassphraseForLength:(self.length - [p getUnicodeLength])]];
        if ([append isEqual: @""]) {
            break;
        } else {
            //don't start with the separator
            if ([p getUnicodeLength]) {
                [p appendString:separator];
            }
            [p appendString:append];
        }
    }
    return p;
}

/**
 Generates a passphrase using the separator code constant
 
 @param separatorType PFSeparatorType separator
 @return passphrase
 */
-(NSString *)generatePassphraseWithSeparatorType:(PFSeparatorType)separatorType {
    [self setSeparatorFromType:separatorType];
    return [self generatePassphrase];
}

/**
 *  Gets a word from our dictionary to fit the length remaining in passphrase
 *
 *  @param length remaining length of passphrase
 *
 *  @return word to fit
 */
-(NSString *)getPassphraseForLength:(NSUInteger)length {
    
    NSString *found;
    int spun = 0;
    
    while (!found && spun <= 40) {
        spun ++;
        int currLength = [SecureRandom randomInt:8] + 4;
        NSArray *curr = self.wordsByLength[@(currLength)];
        if (curr) {
            found = curr[[SecureRandom randomInt:(uint)curr.count]];
        }
    }
    return found;
}
#pragma mark Random Password
/**
 *  Generates a random password of .length
 *
 *  @return randomized password
 */
- (NSString *)generateRandom{
    return [self generateRandomWithLength:self.length];
}

/**
 Generates a random password of length
 
 @param length length of password
 @return randomized password
 */
- (NSString *)generateRandomWithLength:(NSUInteger)length {
    NSUInteger count = [self getCharacterRange];
    NSMutableString *curr = [[NSMutableString alloc] init];
    for(int atLength=0; atLength < length; atLength++){
        int currentRandomPosition = [SecureRandom randomInt:(uint)count];
        int rangeCounter = 0;
        NSString *toAppend;
        for(int atRangeItem = 0; atRangeItem < self.currentRange.count; atRangeItem++) {
            int previousRangeCounter = rangeCounter;
            NSNumber *atRange = self.currentRange[atRangeItem][0];
            rangeCounter += [atRange integerValue];
            if (currentRandomPosition < rangeCounter) {
                id fromRandom = self.currentRange[atRangeItem][1];
                if ([fromRandom isKindOfClass:[NSString class]]) {
                    int num = currentRandomPosition - previousRangeCounter;
                    char from = [(NSString *)fromRandom characterAtIndex:num];
                    toAppend = [NSString stringWithFormat:@"%c",from];
                } else {
                    toAppend = [self randomFromArray:(NSArray *)fromRandom];
                }
                break;
            }
            if (toAppend != nil) {
                break;
            }
        }
        if (toAppend != nil) {
            [curr appendString:toAppend];
        }
    }
    self.currentRange = nil;
    return curr;
}
#pragma mark Random Password Utilities

/**
 Gets the range array for generating random passwords

 @return total number of characters in range
 */
-(NSUInteger)getCharacterRange {
    NSMutableArray *r = [[NSMutableArray alloc] init];
    NSUInteger count = 0;
    if (self.useSymbols) {
        count += [self addRange:self.c.symbols toArray:r];
    }
    if (self.avoidAmbiguous) {
        if (self.caseType == PFUpperCase) {
            count += [self addRange:self.c.nonAmbiguousUpperCase toArray:r];
        } else {
            count += [self addRange:self.c.nonAmbiguousLowerCase toArray:r];
        }
        if (self.useNumbers) {
            count += [self addRange:self.c.nonAmbiguousNumbers toArray:r];
        }
        
    } else {
        if(self.caseType == PFUpperCase) {
            count += [self addRange:self.c.upperCase toArray:r];
        } else {
            count += [self addRange:self.c.lowerCase toArray:r];
        }
        if (self.useNumbers) {
            count += [self addRange:self.c.numbers toArray:r];
        }
    }
    if (self.caseType == PFMixedCase) {
        if (self.avoidAmbiguous) {
            count += [self addRange:self.c.nonAmbiguousUpperCase toArray:r];
        } else {
            count += [self addRange:self.c.upperCase toArray:r];
        }
    }
    if (self.useEmoji) {
        count += PFPasswordNumEmojiInRandom;
        [r addObject:@[@(PFPasswordNumEmojiInRandom), self.emojis]];
    }
    self.currentRange = r;
    return count;
}

/**
 Utility method to add an item to the range

 @param add String to add
 @param a current range
 @return number of characters added
 */
-(NSUInteger)addRange:(NSString *)add toArray:(NSMutableArray *)a {
    NSArray *o = @[@(add.length), add];
    [a addObject:o];
    return add.length;
}

#pragma mark Pattern Password

/**
 Generates a pattern password
 
 @param pattern Pattern to use
 @return generated passwords
 */
-(NSString *)generatePattern: (NSString *)pattern {
    __block NSMutableString *s = [[NSMutableString alloc] init];
    __block bool isEscaped = NO;
    
    //enumerate through the characters typed in the pattern field
    //using 'NSStringEnumerationByComposedCharacterSequences' so that emoji and other extended characters are enumerated as a single character
    [pattern enumerateSubstringsInRange:NSMakeRange(0, pattern.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        
        //dealing with escape - skip to next and place it
        if ([character isEqualToString:@"\\"]) { //the slash will escape the next character and display it exactly as typed
            isEscaped = YES;
            return;
        }
        if (isEscaped){ //we are the character directly after the escape sequence, so display it exactly
            [s appendString:character];
            isEscaped = NO;
            return;
        }
        
        NSString *toAppend;
        //will replace the special pattern characters with their proper randomized value
        if(self.c.patternCharacterToType[character]) {
            PFPatternTypeItem patternType = (PFPatternTypeItem)[(NSNumber *)self.c.patternCharacterToType[character] integerValue];
            switch (patternType) {
                case PFNumberType: //# - Random Number
                    toAppend = [NSString stringWithFormat:@"%d",[SecureRandom randomInt:10]];
                    break;
                case PFLowerCaseWordType: //w - Lowercase word
                    toAppend = [[self randomFromArray:self.englishWords] lowercaseString];
                    break;
                case PFUpperCaseWordType: //W - Uppercase word
                    toAppend = [[self randomFromArray:self.englishWords] uppercaseString];
                    break;
                case PFRandomCaseWordType: //d - random case word
                    toAppend = [[self randomFromArray:self.englishWords] randomCase];
                    break;
                case PFTitleCaseWordType: //D title case word
                    toAppend = [[self randomFromArray:self.englishWords] capitalizedString];
                    break;
                case PFLowerCaseShortWordType: //S - Lowercase short word
                    toAppend = [[self randomFromArray:self.shortWords] lowercaseString];
                    break;
                case PFUpperCaseShortWordType: //s - Uppercase short word
                    toAppend = [[self randomFromArray:self.shortWords] uppercaseString];
                    break;
                case PFRandomCaseShortWordType: //h - random case short word
                    toAppend = [[self randomFromArray:self.shortWords] randomCase];
                    break;
                case PFTitleCaseShortWordType: //H - title case short word
                    toAppend = [[self randomFromArray:self.shortWords] capitalizedString];
                    break;
                case PFSymbolType:  //! - Symbol
                    toAppend = [self randomFromString:self.c.symbols];
                    break;
                case PFLowerCaseCharacterType: //c - Random lowercase character
                    toAppend = [self randomFromString:self.c.lowerCase];
                    break;
                case PFUpperCaseCharacterType: //C - Random uppercase character
                    toAppend = [self randomFromString:self.c.upperCase];
                    break;
                case PFNonAmbiguousCharacterType: //a - Random non ambiguous lowercase
                    toAppend = [self randomFromString:self.c.nonAmbiguousLowerCase];
                    break;
                case PFNonAmbiguousUpperCaseCharacterType: //A - Random non ambiguous uppercase
                    toAppend = [self randomFromString:self.c.nonAmbiguousUpperCase];
                    break;
                case PFNonAmbiguousNumberType: //N - random non-ambiguous number
                    toAppend = [self randomFromString:self.c.nonAmbiguousNumbers];
                    break;
                case PFEmojiType: //e - random emoji
                    toAppend = [self randomFromArray:self.emojis];
                    break;
                case PFLowerCasePhoneticSoundType: //p - random phonetic sound
                    toAppend = [[self randomFromArray:self.phoneticSounds] lowercaseString];
                    break;
                case PFUpperCasePhoneticSoundType: //P - random uppercase phonetic sound
                    toAppend = [[self randomFromArray:self.phoneticSounds] uppercaseString];
                    break;
                case PFRandomCasePhoneticSoundType: //t - random case phonetic sound
                    toAppend = [[self randomFromArray:self.phoneticSounds] randomCase];
                    break;
                case PFTitleCasePhoneticSoundType: //T - title case phonetic sound
                    toAppend = [[self randomFromArray:self.phoneticSounds] capitalizedString];
                    break;
                case PFRandomItemType: //r - random symbol
                    toAppend = [self generateRandomWithLength:1];
                    break;
                    
            }
        } else {
            //not a pattern character, so just append
            toAppend = character;
        }
        
        [s appendString:toAppend];
    }];
    return s;
}
#pragma mark Transform Password

/**
 Transforms the passed in password
 
 @param source password to transform
 @param symbol percent of symbolCase to use
 @param accent percent of accentedCase to use
 @return transformed password
 */
-(NSString *)transformPassword:(NSString *)source symbolCasePrecent:(NSUInteger)symbol accentedCasePercent:(NSUInteger)accent {
    //make sure prefix and suffix are not nil
    if (self.prefix == nil) {
        self.prefix = @"";
    }
    if (self.suffix == nil) {
        self.suffix = @"";
    }
    //add prefix and suffix
    NSString *s = [NSString stringWithFormat:@"%@%@%@",self.prefix,source,self.suffix];
    s = [self caseString:s];
    if (symbol > 0) {
        s = [s symbolCase:symbol];
    }
    if(accent > 0) {
        s = [s accentedCase:accent];
    }
    //checking the find regex
    if(self.find && [self.find isKindOfClass:[NSRegularExpression class]] && self.replace.length > 0) {
        //setting up the regex
        NSMutableString *replaced = [[NSMutableString alloc] initWithString:s];
        NSUInteger matches = [self.find replaceMatchesInString:replaced options:0 range:NSMakeRange(0,replaced.length) withTemplate:self.replace];
        //if we found any matches, update the password
        if(matches) {
            s = replaced;
        }
    }
    //truncate the passweord
    if(self.truncate) {
        __block int i = 0;
        __block NSMutableString *ns = [[NSMutableString alloc] init];
        //need to use enumeration because of the extended characters
        [s enumerateSubstringsInRange:NSMakeRange(0, s.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            if (i < self.truncate) {
                [ns appendString:character];
            }
            i++;
        }];
        s = ns;
    }
    if(self.replaceAmbiguous) {
        s = [s replaceAmbiguous];
    }
    return s;
}
#pragma mark Utility Methods
/**
 *  get a random character as NSString from within a string
 *
 *  @param source source string
 *
 *  @return random character from string
 */
- (NSString *)randomFromString:(NSString *)source {
    char c = [source characterAtIndex:([SecureRandom randomInt:(uint)source.length])];
    return [NSString stringWithFormat:@"%c",c];
}
/**
 *  get a random item from an array
 *
 *  @param source source array
 *
 *  @return random item from array
 */
- (id)randomFromArray:(NSArray *)source {
    return [source objectAtIndex:([SecureRandom randomInt:(uint)source.count])];
}

/**
 Changes the case of the string based upon self.caseType
 
 @param toCase string to
 @return cased string
 */
-(NSString *)caseString:(NSString *)toCase {
    switch (self.caseType) {
        case PFUpperCase:
            return [toCase uppercaseString];
            break;
        case PFMixedCase:
            return [toCase randomCase];
            break;
        case PFTitleCase:
            return [toCase capitalizedString];
            break;
        case PFLowerCase:
            return [toCase lowercaseString];
            break;
        default:
            return toCase;
            break;
    }
}


/**
 Gets the strings that are used to build up the passwords
 
 @param type PFCharacterType to check
 @return character type string
 */
- (NSString *)getPasswordCharacterType:(PFCharacterType)type {
    if (type != PFAllCharacters) {
        return self.c.passwordCharacterTypes[@(type)];
    } else {
        NSMutableString *all = [[NSMutableString alloc] init];
        for (id key in [self.c.passwordCharacterTypes allKeys]) {
            [all appendString:self.c.passwordCharacterTypes[key]];
        }
        return all;
    }
}

/**
 Returns if a character is part of password character type item
 
 @param type PFCharacterType - i.e UpperCase
 @param character character to check
 @return true if character is part of builder item
 */
- (BOOL)isCharacterType:(PFCharacterType)type character:(NSString *)character {
    return [(NSString *)self.c.passwordCharacterTypes[@(type)] containsString:character];
}
/**
 *  Loads up our dictionary, and removes 'bad' words to generate pattern passwords.
 *  The results are cached so that the parsing only happens on app install or upgrade
 */
- (void)loadWords {
    //loading up our word list
    
    NSString *wordsDataPath = [[NSBundle mainBundle] pathForResource:@"frequency_lists" ofType:@"json"];
    NSString *badWordsDataPath = [[NSBundle mainBundle] pathForResource:@"bad_words" ofType:@"json"];
    NSString *emojiDataPath = [[NSBundle mainBundle] pathForResource:@"emojis" ofType:@"txt"];
    NSString *phoneticDataPath = [[NSBundle mainBundle] pathForResource:@"sounds" ofType:@"json"];
    
    NSString *wordsArchivePath = [self getApplicationSupportDirectory:EnglishWordsArchiveFilename];
    NSString *shortWordsArchivePath = [self getApplicationSupportDirectory:ShortWordsArchiveFilename];
    NSString *wordsByLengthArchivePath = [self getApplicationSupportDirectory:WordsByLengthWordsArchiveFilename];
    NSString *emojiArchivePath = [self getApplicationSupportDirectory:EmojiArchiveFilename];
    NSString *phoneticSoundsArchivePath = [self getApplicationSupportDirectory:PhoneticSoundsArchiveFilename];
    
    NSArray *dataPaths = @[wordsDataPath, badWordsDataPath, emojiDataPath, phoneticDataPath];
    NSArray *archivePaths = @[wordsArchivePath,shortWordsArchivePath,wordsByLengthArchivePath,emojiArchivePath,phoneticSoundsArchivePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL missingArchives = NO;
    for (NSString *path in archivePaths) {
        if (![fileManager fileExistsAtPath:path]) {
            missingArchives = YES;
            break;
        }
    }
    if (!missingArchives) {
        __weak PasswordFactory* weakSelf = self;
        //getting the date of the newest data item
        NSString *newestDataPath = [dataPaths sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [[weakSelf getFileModificationDate:obj2] compare:[weakSelf getFileModificationDate:obj1]];
        }][0];
        //getting the date of the earliest archive item
        NSString *oldestArchivePath = [archivePaths sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [[weakSelf getFileModificationDate:obj1] compare:[weakSelf getFileModificationDate:obj2]];
        }][0];
        
        NSDate *newestDataDate = [self getFileModificationDate:newestDataPath];
        NSDate *oldestArchiveDate = [self getFileModificationDate:oldestArchivePath];
        //checking to see if our cache archives are older than the data
        if ([newestDataDate compare:oldestArchiveDate] == NSOrderedAscending) {
            //cache data is newer than archive, so load data
            self.englishWords = [NSKeyedUnarchiver unarchiveObjectWithFile:wordsArchivePath];
            self.shortWords = [NSKeyedUnarchiver unarchiveObjectWithFile:shortWordsArchivePath];
            self.wordsByLength = [NSKeyedUnarchiver unarchiveObjectWithFile:wordsByLengthArchivePath];
            self.emojis = [NSKeyedUnarchiver unarchiveObjectWithFile:emojiArchivePath];
            NSDictionary *phoneticData = [NSKeyedUnarchiver unarchiveObjectWithFile:phoneticSoundsArchivePath];
            if (phoneticData.count >1) {
                self.phoneticSoundsTwo = phoneticData[@"two"];
                self.phoneticSoundsThree = phoneticData[@"three"];
                self.phoneticSounds = [self.phoneticSoundsTwo arrayByAddingObjectsFromArray:self.phoneticSoundsThree];
            }
        }
        //checking to see if all of the archives loaded by checking the count of items in the dictionary
        if (self.englishWords.count > 0 && self.shortWords > 0 && self.wordsByLength.count > 0 && self.emojis.count > 0 && self.phoneticSoundsTwo > 0 && self.phoneticSoundsThree > 0) {
            return;
        }
    }

    //Archives didn't load, so parse the data files
    
    //parsing out the data for our word lists
    NSData *jsonData = [NSData dataWithContentsOfFile:wordsDataPath];
    NSDictionary *dicts = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSMutableArray *e = [[NSMutableArray alloc] init];
    NSMutableArray *es = [[NSMutableArray alloc] init];
    NSCharacterSet *charSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSMutableDictionary *wl = [[NSMutableDictionary alloc] init];
    //loading up our 'bad' words
    
    NSData *bData = [NSData dataWithContentsOfFile:badWordsDataPath];
    self.badWords = (NSArray *)[NSJSONSerialization JSONObjectWithData:bData options:0 error:nil];
    
    for (NSString *w in [dicts objectForKey:@"english"]) {
        if ([w rangeOfCharacterFromSet:charSet].length == 0){ //remove any words that are not composed of alphanumeric characters
            if (![self isBadWord:w]) { //remove bad words
                if (w.length > 6) { //main word list uses only words of length 6 or more
                    [e addObject:w];
                }
                if (w.length > 3 && w.length < 6) { //adding words of length 3-6 to short words
                    [es addObject:w];
                }
                //setting up words by length (wl)
                if ([wl objectForKey:@(w.length)]) { //seeing if there already is length in words by length
                    [(NSMutableArray *)wl[@(w.length)] addObject: w];
                } else { //if not make the array for length
                    NSMutableArray *a = [[NSMutableArray alloc] init];
                    if (w != nil) {
                        [a addObject:w];
                    }
                    [wl setObject:a forKey:@(w.length)];
                }
            }
        }
    }
    if (e.count == 0 ||  es.count == 0 || wl.count == 0) {
#ifdef IS_MACOS
        AppDelegate *d = [NSApplication sharedApplication].delegate;
        d.loadError = @{
                        @"MESSAGE": NSLocalizedString(@"errorDataLoadFail", comment: @"Loading data failed"),
                        @"CODE" : @(PFDataLoadError)
                        };
#endif
    }
    self.englishWords = [[NSArray alloc] initWithArray:e];
    self.shortWords = [[NSArray alloc] initWithArray:es];
    self.wordsByLength = [[NSDictionary alloc] initWithDictionary:wl];
    //Saving our word lists so we don't have to run this every time
    [NSKeyedArchiver archiveRootObject:self.englishWords toFile:wordsArchivePath];
    [NSKeyedArchiver archiveRootObject:self.shortWords toFile:shortWordsArchivePath];
    [NSKeyedArchiver archiveRootObject:self.wordsByLength toFile:wordsByLengthArchivePath];
    
    //loading up the emojis
    NSString *emojiText = [NSString stringWithContentsOfFile:emojiDataPath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *em = [[NSMutableArray alloc] init];
    //using the enumerator because some emojis are multibyte strings
    [emojiText enumerateSubstringsInRange:NSMakeRange(0, emojiText.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        if (![character isEqualToString:@"\n"]) {
            [em addObject:character];
        }
    }];
    self.emojis = (NSArray *)em;
    [NSKeyedArchiver archiveRootObject:self.emojis toFile:emojiArchivePath];
    
    //loading up phonetic sounds
    NSData *pdata = [NSData dataWithContentsOfFile:phoneticDataPath];
    NSDictionary *pjson = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:pdata options:0 error:nil];
    NSMutableDictionary *pdict = [[NSMutableDictionary alloc] init];
    pdict[@"two"] = [[NSMutableArray alloc] init];
    pdict[@"three"] = [[NSMutableArray alloc] init];
    for(NSString *ps in pjson) {
        if (ps.length == 2) {
            [pdict[@"two"] addObject:ps];
        } else if (ps.length == 3) {
            [pdict[@"three"] addObject:ps];
        }
    }
    [NSKeyedArchiver archiveRootObject:pdict toFile:phoneticSoundsArchivePath];
    self.phoneticSoundsThree = pdict[@"three"];
    self.phoneticSoundsTwo = pdict[@"two"];
    self.phoneticSounds = [self.phoneticSoundsTwo arrayByAddingObjectsFromArray:self.phoneticSoundsThree];
}


/**
 Gets file modification date for a path

 @param path path to get date
 @return modification date
 */
-(NSDate *)getFileModificationDate:(NSString *)path {
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    if (attributes != nil) {
        return attributes[@"NSFileModificationDate"];
    }
    return nil;
}
/**
 *  Gets path to Application support directory for the app to allow saving of users and other data
 *
 *  @param withFile filename
 *
 *  @return path of file
 */
-(NSString *)getApplicationSupportDirectory:(NSString *)withFile {
    
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appS = [paths firstObject];
    NSString *executableName =
    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"]; //appending the app name
    appS = [appS stringByAppendingPathComponent:executableName];
    
    //Creating the directory if it needs to be
    if(![fm fileExistsAtPath:appS]) {
        
        [fm createDirectoryAtPath:appS
      withIntermediateDirectories:YES
                       attributes:nil
                            error:&error];
    }
    
    appS = [appS stringByAppendingPathComponent:withFile];
    return appS;
}
/**
 *  Rudimentary bad word filter, uses an array of 'bad' words to determine if passed in word is bad
 *
 *  @param word word to check to see if it is bad
 *
 *  @return YES if it is a 'bad' word 'NO' if it is not
 */
- (BOOL)isBadWord:(NSString *)word {
    
    if ([self.badWords containsObject:word]) {
        return YES;
    }
    
    //Searching for substrings within the current word
    for (int i=0; i< self.badWords.count; i++) {
        NSString *currWord = self.badWords[i];
        if (currWord.length < 4) { //do not search if word is less than 4 characters
            continue;
        }
        if ([word rangeOfString:currWord].location != NSNotFound) { //has a substring of that word, so it is also a bad word
            return YES;
        }
    }
    return NO;
}

/**
 Returns all the passsword types in a dictionary keyed by PFPasswordType
 
 @return all password types
 */
-(NSDictionary *)getAllPasswordTypes {
    return self.c.passwordTypes;
}

@end





