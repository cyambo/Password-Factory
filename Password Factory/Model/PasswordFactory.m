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


@interface PasswordFactory ()

@property (nonatomic, strong) NSString *separator;
@property (nonatomic, strong) NSMutableArray *currentRange;
@property (nonatomic, strong) NSArray *englishWords;
@property (nonatomic, strong) NSArray *shortWords;
@property (nonatomic, strong) NSDictionary *wordsByLength;
@property (nonatomic, strong) NSArray *emojis;
@property (nonatomic, strong) NSArray *badWords;
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
        self.postfix = @"";
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
    while (p.length < self.length) {
        NSString *append = [self caseString:[self getPronounceableForLength:(self.length - p.length)]];
        if ([append isEqual: @""]) {
            break;
        } else {
            if (p.length) {
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
        return [self randomFromArray:self.c.phoneticSoundsTwo];
    } else if (length == 3) { //return a three length sound
        return [self randomFromArray:self.c.phoneticSoundsThree];
    }
    else { //return any length sound
        NSUInteger numSyllables = [self randomNumber:3] + 1;
        NSMutableString *sound = [[NSMutableString alloc] init];
        for(int i = 0; i <= numSyllables; i++) {
            [sound appendString:[self randomFromArray:self.c.phoneticSounds]];
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
    switch (separatorType) {
        case PFNoSeparator:
            sep = @"";
            break;
        case PFHyphenSeparator:
            sep = @"-";
            break;
        case PFSpaceSeparator:
            sep = @" ";
            break;
        case PFUnderscoreSeparator:
            sep = @"_";
            break;
        case PFNumberSeparator:
            sep = [NSString stringWithFormat:@"%d",[self randomNumber:10]];
            break;
        case PFSymbolSeparator:
            sep = [self randomFromString:self.c.symbols];
            break;
        case PFCharacterSeparator:
            sep = [self randomFromString:self.c.nonAmbiguousUpperCase];
            break;
        case PFEmojiSeparator:
            sep = [self.emojis objectAtIndex:[self randomNumber:[self randomNumber:(uint)self.emojis.count]]];
            break;
        case PFRandomSeparator:
            sep = [self generateRandomWithLength:1];
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
    while (p.length < self.length) {
        NSString *append = [self caseString:[self getPassphraseForLength:(self.length - p.length)]];
        if ([append isEqual: @""]) {
            break;
        } else {
            //don't start with the separator
            if (p.length) {
                [p appendString:separator];
            }
            [p appendString:append];
        }
    }
    return p;
}

/**
 Generates a passphrase using the separator code constant

 @param PFSeparatorType separator
 @return generated passphrase
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
        int currLength = [self randomNumber:8] + 4;
        NSArray *curr = self.wordsByLength[@(currLength)];
        if (curr) {
            found = curr[[self randomNumber:(uint)curr.count]];
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
    [self setCharacterRange];
    NSMutableString *curr = [[NSMutableString alloc] init];
    for(int i=0;i<length;i++){
        int at = [self randomNumber:(uint)self.currentRange.count];
        [curr appendString:[self.currentRange objectAtIndex:at]];
    }
    return curr;
}
#pragma mark Random Password Utilities
/**
 *  Gets the characters used for a random password based upon settings
 */
- (void)setCharacterRange {
    NSMutableString *tmp = [[NSMutableString alloc] init];
    if (self.useSymbols) {
        [tmp appendString:self.c.symbols];
    }
    if (self.avoidAmbiguous) {
        if (self.caseType == PFUpperCase) {
            [tmp appendString:self.c.nonAmbiguousUpperCase];
        } else {
            [tmp appendString:self.c.nonAmbiguousLowerCase];
        }
        if (self.useNumbers) {
            [tmp appendString:self.c.nonAmbiguousNumbers];
        }
        
    } else {
        if(self.caseType == PFUpperCase) {
            [tmp appendString:self.c.upperCase];
        } else {
            [tmp appendString:self.c.lowerCase];
        }
        if (self.useNumbers) {
            [tmp appendString:self.c.numbers];
        }
    }
    if (self.caseType == PFMixedCase) {
        if (self.avoidAmbiguous) {
            [tmp appendString:self.c.nonAmbiguousUpperCase];
        } else {
            [tmp appendString:self.c.upperCase];
        }
    }

    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    //using a dictionary to make all the letters unique
    for(int i = 0; i < tmp.length; i++) {
        NSRange r = NSMakeRange(i, 1);
        d[[tmp substringWithRange:r]] = @(1);
    }
    self.currentRange = [[d allKeys] mutableCopy];
    if (self.useEmoji) {
        //only putting a small number of random emojis in the pool
        //because if we use all of them it messes up the balance of characters and displays
        //mostly emoji
        for (int i = 0; i < PFPasswordNumEmojiInRandom; i++) {
            [self.currentRange addObject:[self randomFromArray:self.emojis]];
        }
    }
    
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
                    toAppend = [NSString stringWithFormat:@"%d",[self randomNumber:10]];
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
                    toAppend = [[self randomFromArray:self.c.phoneticSounds] lowercaseString];
                    break;
                case PFUpperCasePhoneticSoundType: //P - random uppercase phonetic sound
                    toAppend = [[self randomFromArray:self.c.phoneticSounds] uppercaseString];
                    break;
                case PFRandomCasePhoneticSoundType: //t - random case phonetic sound
                    toAppend = [[self randomFromArray:self.c.phoneticSounds] randomCase];
                    break;
                case PFTitleCasePhoneticSoundType: //T - title case phonetic sound
                    toAppend = [[self randomFromArray:self.c.phoneticSounds] capitalizedString];
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
-(NSString *)transformPassword:(NSString *)source symbolCasePrecent:(NSUInteger)symbol accentedCasePercent:(NSUInteger)accent {
    //add prefix and postfix
    NSString *s = [NSString stringWithFormat:@"%@%@%@",self.prefix,source,self.postfix];
    s = [self caseString:s];
    if (symbol > 0) {
        s = [s symbolCase:symbol];
    }
    if(accent > 0) {
        s = [s accentedCase:accent];
    }
    if(self.replaceAmbiguous) {
        
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
    char c = [source characterAtIndex:([self randomNumber:(uint)source.length])];
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
    return [source objectAtIndex:([self randomNumber:(uint)source.count])];
}
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

 @param  PFCharacterType
 @return string containing all the items of that type
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

 @param PFCharacterType - i.e UpperCase
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
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"frequency_lists" ofType:@"json"];
    NSString *badWordsPath = [[NSBundle mainBundle] pathForResource:@"bad_words" ofType:@"json"];
    NSString *emojiPath = [[NSBundle mainBundle] pathForResource:@"emojis" ofType:@"txt"];
    
    NSString *englishWordsPath = [self getApplicationSupportDirectory:EnglishWordsArchiveFilename];
    NSString *shortWordsPath = [self getApplicationSupportDirectory:ShortWordsArchiveFilename];
    NSString *wordsByLengthPath = [self getApplicationSupportDirectory:WordsByLengthWordsArchiveFilename];
    NSString *emojiArchivePath = [self getApplicationSupportDirectory:EmojiArchiveFilename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Checking to see if our cached files exist and are newer than our data files, if so, load them instead of parsing
    if ([fileManager fileExistsAtPath:englishWordsPath] &&
        [fileManager fileExistsAtPath:shortWordsPath] &&
        [fileManager fileExistsAtPath:wordsByLengthPath] &&
        [fileManager fileExistsAtPath:emojiPath]) {
        NSDate *eDate = [fileManager attributesOfItemAtPath:englishWordsPath error:nil][@"NSFileCreationDate"];
        NSDate *sDate = [fileManager attributesOfItemAtPath:shortWordsPath error:nil][@"NSFileCreationDate"];
        NSDate *wDate = [fileManager attributesOfItemAtPath:wordsByLengthPath error:nil][@"NSFileCreationDate"];
        NSDate *jDate = [fileManager attributesOfItemAtPath:jsonPath error:nil][@"NSFileCreationDate"];
        
        //comparing file dates to json path create date
        if ([eDate compare:jDate] == NSOrderedDescending && [sDate compare:jDate] == NSOrderedDescending && [wDate compare:jDate] == NSOrderedDescending) {
            self.englishWords = [NSKeyedUnarchiver unarchiveObjectWithFile:englishWordsPath];
            self.shortWords = [NSKeyedUnarchiver unarchiveObjectWithFile:shortWordsPath];
            self.wordsByLength = [NSKeyedUnarchiver unarchiveObjectWithFile:wordsByLengthPath];
            self.emojis = [NSKeyedUnarchiver unarchiveObjectWithFile:emojiArchivePath];
        }
        //did we load the archive?
        if (self.englishWords.count > 0 && self.shortWords > 0 && self.wordsByLength.count > 0 && self.emojis.count > 0) {
            return;
        }
    }
    //Archives didn't load, so parse out the words manually
    //parsing out the data for our word lists
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *dicts = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSMutableArray *e = [[NSMutableArray alloc] init];
    NSMutableArray *es = [[NSMutableArray alloc] init];
    NSCharacterSet *charSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    NSMutableDictionary *wl = [[NSMutableDictionary alloc] init];
    //loading up our 'bad' words
    
    NSData *bData = [NSData dataWithContentsOfFile:badWordsPath];
    self.badWords = (NSArray *)[NSJSONSerialization JSONObjectWithData:bData options:0 error:nil];
    
    for (NSString *w in [dicts objectForKey:@"english"]) {
        if ([w rangeOfCharacterFromSet:charSet].length == 0){
            if (![self isBadWord:w]) { //remove bad words
                if (w.length > 6) { //main word list uses only words of length 6 or more
                    [e addObject:w];
                }
                if (w.length > 3 && w.length < 6) {
                    [es addObject:w];
                }
                if ([wl objectForKey:@(w.length)]) {
                    [(NSMutableArray *)wl[@(w.length)] addObject: w];
                } else {
                    NSMutableArray *a = [[NSMutableArray alloc] initWithObjects:w, nil];
                    [wl setObject:a forKey:@(w.length)];
                }
            }
        }
    }
    self.englishWords = [[NSArray alloc] initWithArray:e];
    self.shortWords = [[NSArray alloc] initWithArray:es];
    self.wordsByLength = [[NSDictionary alloc] initWithDictionary:wl];
    //Saving our word lists so we don't have to run this every time
    [NSKeyedArchiver archiveRootObject:self.englishWords toFile:englishWordsPath];
    [NSKeyedArchiver archiveRootObject:self.shortWords toFile:shortWordsPath];
    [NSKeyedArchiver archiveRootObject:self.wordsByLength toFile:wordsByLengthPath];
    
    //loading up the emojis
    NSString *emojiText = [NSString stringWithContentsOfFile:emojiPath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *em = [[NSMutableArray alloc] init];
    //using the enumerator because some emojis are multibyte strings
    [emojiText enumerateSubstringsInRange:NSMakeRange(0, emojiText.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        if (![character isEqualToString:@"\n"]) {
            [em addObject:character];
        }
    }];
    self.emojis = (NSArray *)em;
    [NSKeyedArchiver archiveRootObject:self.emojis toFile:emojiArchivePath];
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
 Generates a cryptographic random number

 @param limit upper limit of number
 @return random uint
 */
-(uint)randomNumber:(uint)limit {
    int32_t randomNumber = 0;
    uint result = SecRandomCopyBytes(kSecRandomDefault, 4, (uint8_t*) &randomNumber);
    if(result == 0) {
        return randomNumber % limit;
    } else {
        NSLog(@"SecRandomCopyBytes failed for some reason");
    }
    return 1;
}


/**
 Returns all the passsword types in a dictionary keyed by PFPasswordType

 @return all password types
 */
-(NSDictionary *)getAllPasswordTypes {
    return self.c.passwordTypes;
}

@end





