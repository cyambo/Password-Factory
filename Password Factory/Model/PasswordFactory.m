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
- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [self loadWords];
        self.c = [PasswordFactoryConstants get];

        self.length = 5;
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
        if (self.caseType == PFUpper) {
            [tmp appendString:self.c.nonAmbiguousUpperCase];
        } else {
            [tmp appendString:self.c.nonAmbiguousLowerCase];
        }
        if (self.useNumbers) {
            [tmp appendString:self.c.nonAmbiguousNumbers];
        }
        
    } else {
        if(self.caseType == PFUpper) {
            [tmp appendString:self.c.upperCase];
        } else {
            [tmp appendString:self.c.lowerCase];
        }
        if (self.useNumbers) {
            [tmp appendString:self.c.numbers];
        }
    }
    if (self.caseType == PFMixed) {
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
        
        //check to see if the character is one of the special pattern characters (#!wW etc)
        int patternType = (int)[[self.c.characterPattern objectForKey:character] integerValue];
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
        switch (patternType) {
            case 0: //is not a pattern character, so append directly to the password
                toAppend = character;
                break;
            case 1: //# - Random Number
                toAppend = [NSString stringWithFormat:@"%d",[self randomNumber:10]];
                break;
            case 2: //w - Lowercase word
                toAppend = [[self randomFromArray:self.englishWords] lowercaseString];
                break;
            case 3: //W - Uppercase word
                toAppend = [[self randomFromArray:self.englishWords] uppercaseString];
                break;
            case 4: //S - Lowercase short word
                toAppend = [[self randomFromArray:self.shortWords] lowercaseString];
                break;
            case 5: //s - Uppercase short word
                toAppend = [[self randomFromArray:self.shortWords] uppercaseString];
                break;
            case 6:  //! - Symbol
                toAppend = [self randomFromString:self.c.symbols];
                break;
            case 7: //c - Random lowercase character
                toAppend = [self randomFromString:self.c.lowerCase];
                break;
            case 8: //C - Random uppercase character
                toAppend = [self randomFromString:self.c.upperCase];
                break;
            case 9: // - Random non ambiguous lowercase

                toAppend = [self randomFromString:self.c.nonAmbiguousLowerCase];
                break;
            case 10: // - Random non ambiguous uppercase
                toAppend = [self randomFromString:self.c.nonAmbiguousUpperCase];
                break;
            case 11: //random non-ambiguous number
                toAppend = [self randomFromString:self.c.nonAmbiguousNumbers];
                break;
            case 12: //random emoji
                toAppend = [self randomFromArray:self.emojis];
                break;
            case 13: //random phonetic sound
                toAppend = [[self randomFromArray:self.c.phoneticSounds] lowercaseString];
                break;
            case 14: //random uppercase phonetic sound
                toAppend = [[self randomFromArray:self.c.phoneticSounds] uppercaseString];
                break;
            case 15: //random symbol
                toAppend = [self generateRandomWithLength:1];
                break;
            case 16: //random case word
                toAppend = [[self randomFromArray:self.englishWords] randomCase];
                break;
            case 17: //title case word
                toAppend = [[self randomFromArray:self.englishWords] capitalizedString];
                break;
            case 18: //random case short word
                toAppend = [[self randomFromArray:self.shortWords] randomCase];
                break;
            case 19: //title case short word
                toAppend = [[self randomFromArray:self.shortWords] capitalizedString];
                break;
            case 20: //random case phonetic sound
                toAppend = [[self randomFromArray:self.c.phoneticSounds] randomCase];
                break;
            case 21: //title case phonetic sound
                toAppend = [[self randomFromArray:self.c.phoneticSounds] capitalizedString];
                break;
                
        }
        [s appendString:toAppend];
    }];
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
        case PFUpper:
            return [toCase uppercaseString];
            break;
        case PFMixed:
            return [toCase randomCase];
            break;
        case PFTitle:
            return [toCase capitalizedString];
            break;
        case PFLower:
        default:
            return [toCase lowercaseString];
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
    return 0;
}

/**
 Gets name of password type for PFPasswordType

 @param type PFPasswordType
 @return String of name
 */
-(NSString *)getNameForPasswordType:(PFPasswordType)type {
    return [self.c.passwordTypes objectForKey:@(type)];
}

/**
 Returns all the passsword types in a dictionary keyed by PFPasswordType

 @return all password types
 */
-(NSDictionary *)getAllPasswordTypes {
    return self.c.passwordTypes;
}

/**
 Gets the password type by index (0, 1, etc) whih sorts by the PFPasswordType value

 @param index Index - 0, 1, 2 etc
 @return PFPasswordType matching index
 */
-(PFPasswordType)getPasswordTypeByIndex:(NSInteger)index {
    
    NSArray *keys = [[self.c.passwordTypes allKeys] sortedArrayUsingSelector:@selector(compare:)]; //get sorted keys
    if (index >= 0 && index < keys.count) {
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
    NSArray *keys = [[self.c.passwordTypes allKeys] sortedArrayUsingSelector:@selector(compare:)]; //get sorted keys
    for(int i = 0; i < keys.count; i++) {
        if ((PFPasswordType)[(NSNumber *)keys[i] integerValue] == type) {
            return i;
        }
    }
    return 0;
}
@end





