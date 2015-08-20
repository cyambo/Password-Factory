//
//  PasswordFactory.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "PasswordFactory.h"
#import "constants.h"
#import "NSString+RandomCase.h"
static NSString* symbols;
static NSString* upperCase;
static NSString* lowerCase;
static NSString* numbers;
static NSString* nonAmbiguousUpperCase;
static NSString* nonAmbiguousLowerCase;
static NSString* nonAmbiguousNumbers;
static NSDictionary* characterPattern;
static NSArray* phoeneticSounds;
static NSArray* phoeneticSoundsTwo;
static NSArray* phoeneticSoundsThree;
static NSDictionary* pronounceableSep;


@interface PasswordFactory ()
@property (nonatomic, strong) NSMutableString *currentRange;

@property (nonatomic, strong) NSArray *englishWords;
@property (nonatomic, strong) NSArray *shortWords;
@property (nonatomic, strong) NSDictionary *wordsByLength;
@property (nonatomic, strong) NSArray *badWords;
@end

@implementation PasswordFactory
- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [self loadWords];
        [self setStatics];
        self.useSymbols = YES;
        self.avoidAmbiguous = YES;
        self.mixedCase = YES;
        self.passwordLength = 5;
        
    }
    return self;
}

#pragma mark Pronounceable Password
/**
 *  Gets pronounceable separator based on radio button
 *
 *  @param selectedTitle title of radio button
 *
 *  @return a separator for pronounceable strings
 */
- (NSString *)getPronounceableSeparator:(NSString *)selectedTitle {
    return [self getPronounceableSeparatorWithInt:(int)[[pronounceableSep objectForKey:selectedTitle] integerValue]];
}
- (NSString *)getPronounceableSeparatorWithInt:(int)separator {
    NSString *sep = @"";
    switch (separator) {
            
            
        case 1:
            sep = @"-";
            break;
        case 2:
            sep = [NSString stringWithFormat:@"%d",arc4random()%10];
            break;
        case 3:
            sep = @"";
            break;
        case 4:
            sep = [NSString stringWithFormat:@"%c",[self randomFromString:symbols]];
            break;
        case 5:
            sep = [NSString stringWithFormat:@"%c",[self randomFromString:nonAmbiguousUpperCase]];
            break;
        case 6:
            sep = @" ";
            break;
        default:
            sep = @"";
            break;
    }
    return sep;
}
/**
 *  generate a 'pronounceable' password
 *
 *  @param selectedTitle Title of separator radio button
 *
 *  @return 'pronunceable' password
 */
- (NSString *)generatePronounceable:(id)selectedTitle {

    NSMutableString *p = [[NSMutableString alloc] init];
    int st = (int)[selectedTitle integerValue];
    NSString *sep;
    if ([selectedTitle isKindOfClass:[NSString class]]) {
        sep = [self getPronounceableSeparator:selectedTitle];
    }else if (st >=0 && st <=5) {
        NSLog(@"%d",st);
        sep = [self getPronounceableSeparatorWithInt:st+1];
    }
    int i = 0;
    while (p.length < self.passwordLength) {
        NSString *append = [[self getPronounceableForLength:(self.passwordLength - p.length)] lowercaseString];
        if ([append isEqual: @""]) {
            break;
        } else {
            [p appendString:append];
        }
        if (i%2 == 1 && p.length < self.passwordLength) {
            [p appendString:sep];
        }
        i++;
        
    }
    
    return p;
    
}

/**
 *  with pronnounceable we don't want to exceed the set password length, so choose the appropriate size 'sound'
 *
 *  @param length remaining length left in password string
 *
 *  @return a pronounceable 'piece'
 */
- (NSString *)getPronounceableForLength:(NSUInteger)length {
    if (length < 2) {
        return @"";
    }
    else if (length == 2) {
        return [self randomFromArray:phoeneticSoundsTwo];
    } else if (length == 3) {
        return [self randomFromArray:phoeneticSoundsThree];
    }
    else {
        return [self randomFromArray:phoeneticSounds];
    }
    return @"";
    
}
#pragma mark Passphrase
/**
 *  Generates a passphrase by combining various length words
 *
 *  @param separator string to use to separate words
 *  @param caseType  type of case to use, upper, lower, mixed, capitalized - see constants.h for values
 *
 *  @return <#return value description#>
 */
-(NSString *)generatePassphrase:(NSString *)separator caseType:(int)caseType {

    NSMutableString *p = [[NSMutableString alloc] init];

    while (p.length < self.passwordLength) {
        NSString *append = [self getPassphraseForLength:(self.passwordLength - p.length)];
        switch (caseType) {
            case PFPassphraseUseUpperCase:
                append = [append uppercaseString];
                break;
            case PFPassphraseUseMixedCase:
                append = [append randomCase];
                break;
            case PFPassphraseUseTitleCase:
                append = [append capitalizedString];
                break;
            case PFPassphraseUseLowerCase:
            default:
                append = [append lowercaseString];
                break;
        }
        if ([append isEqual: @""]) {
            break;
        } else {
            [p appendString:append];
        }
        if (p.length < self.passwordLength) {
            [p appendString:separator];
        }

        
    }
    
    return p;
}
-(NSString *)getPassphraseForLength:(NSUInteger)length {

    NSString *found;
    int spun = 0;
    if (length > 11) {
        length = 11;
    } else if (length < 4) {
        length = 4;
    }
    while (!found && spun <= 40) {
        spun ++;
        int currLength = (arc4random() % 8) + 4;
        NSArray *curr = self.wordsByLength[@(currLength)];
        if (curr) {
            found = curr[arc4random() % curr.count];
        }
        
    }
    return found;
}
#pragma mark Random Password
/**
 *  Generates a random password
 *
 *  @return randomized password based on settings
 */
- (NSString *)generateRandom {
    [self setCharacterRange];
    NSMutableString *curr = [[NSMutableString alloc] init];
    for(int i=0;i<self.passwordLength;i++){
        int at = arc4random() % [self.currentRange length];
        char charAt = [self.currentRange characterAtIndex:at];
        [curr appendFormat:@"%c",charAt];
        
        
    }
    
    return curr;
    
}
/**
 *  Gets the characters used for a random password based upon settings
 */
- (void)setCharacterRange {
    NSMutableString *tmp = [[NSMutableString alloc] init];
    if (self.useSymbols) {
        [tmp appendString:symbols];
    }
    if (self.avoidAmbiguous) {
        [tmp appendString:nonAmbiguousLowerCase];
        [tmp appendString:nonAmbiguousNumbers];
    } else {
        [tmp appendString:lowerCase];
        [tmp appendString:numbers];
    }
    if (self.mixedCase) {
        if (self.avoidAmbiguous) {
            [tmp appendString:nonAmbiguousUpperCase];
        } else {
            [tmp appendString:upperCase];
        }
    }
    self.currentRange = [self removeDuplicateChars:tmp];
}
#pragma mark Pattern Password
/**
 *  quick parser to parse the pattern string and build out a password
 *
 *  @param pattern Password pattern
 *
 *  @return a pattern generated password
 */
- (NSString *)generatePattern: (NSString *)pattern {
    int l = (int)self.englishWords.count;
    int sl = (int)self.shortWords.count;
    NSMutableString *s = [[NSMutableString alloc] init];
    bool isEscaped = NO;
    for (int i=0; i< pattern.length; i++) {
        char c = [pattern characterAtIndex:i];
        int at = (int)[[characterPattern objectForKey:[NSString stringWithFormat:@"%c",c]] integerValue];
        NSString *currVal;
        //dealing with escape - skip to next and place it
        if (c == '\\') {
            isEscaped = YES;
            continue;
        }
        if (isEscaped){
            [s appendString:[NSString stringWithFormat:@"%c",c]];
            isEscaped = NO;
            continue;
        }
        //dealing with pattern characters
        switch (at) {
            case 0:
                [s appendString:[NSString stringWithFormat:@"%c",c]];
                break;
            case 1:
                [s appendString:[NSString stringWithFormat:@"%d",arc4random()%10]];
                break;
            case 2:
                currVal = [self.englishWords objectAtIndex:arc4random() % l];
                [s appendString:[currVal lowercaseString]];
                break;
            case 3:
                currVal = [self.englishWords objectAtIndex:arc4random() % l];
                [s appendString:[currVal uppercaseString]];
                break;
            case 4:
                currVal = [self.shortWords objectAtIndex:arc4random() % sl];
                [s appendString:[currVal lowercaseString]];
                break;
            case 5:
                currVal = [self.shortWords objectAtIndex:arc4random() % sl];
                [s appendString:[currVal uppercaseString]];
                break;
            case 6:
                c = [symbols characterAtIndex:(arc4random() % symbols.length)];
                [s appendString:[NSString stringWithFormat:@"%c",c]];
                break;
            case 7:
                if (self.avoidAmbiguous) {
                    c = [nonAmbiguousLowerCase characterAtIndex:(arc4random() % nonAmbiguousLowerCase.length)];
                } else {
                    c = [lowerCase characterAtIndex:(arc4random() % lowerCase.length)];
                }
                [s appendString:[NSString stringWithFormat:@"%c",c]];
                break;
            case 8:
                if (self.avoidAmbiguous) {
                    c = [nonAmbiguousUpperCase characterAtIndex:(arc4random() % nonAmbiguousUpperCase.length)];
                } else {
                    c = [upperCase characterAtIndex:(arc4random() % upperCase.length)];
                }
                [s appendString:[NSString stringWithFormat:@"%c",c]];
                break;
                
                
                
        }
    }
    return s;
}

#pragma mark Utility Methods

/**
 *  get a random character from within a string
 *
 *  @param source source string
 *
 *  @return random character from string
 */
- (char)randomFromString:(NSString *)source {
    return [source characterAtIndex:(arc4random() % source.length)];
}
/**
 *  get a random item from an array
 *
 *  @param source source array
 *
 *  @return random item from array
 */
- (id)randomFromArray:(NSArray *)source {
    return [source objectAtIndex:(arc4random() % source.count)];
}
/**
 *  building out the static variables used to generate password
 */
- (void)setStatics {
    symbols = @"!@#$%^&*(){}[];:.\"<>?/\\-_+=|\'";
    upperCase = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    lowerCase = @"abcdefghijklmnopqrstuvwxyz";
    nonAmbiguousUpperCase = @"ABCDEFGHJKLMNPQRSTUVWXYZ";
    nonAmbiguousLowerCase = @"abcdefghijkmnpqrstuvwxyz";
    numbers = @"0123456789";
    nonAmbiguousNumbers = @"23456789";
    phoeneticSoundsTwo = @[@"BA",@"BE",@"BO",@"BU",@"BY",@"DA",@"DE",@"DI",@"DO",@"DU",@"FA",@"FE",@"FI",@"FO",@"FU",@"GA",@"GE",@"GI",@"GO",@"GU",@"HA",@"HE",@"HI",@"HO",@"HU",@"JA",@"JE",@"JI",@"JO",@"JU",@"KA",@"KE",@"KI",@"KO",@"KU",@"LA",@"LE",@"LI",@"LO",@"LU",@"MA",@"ME",@"MI",@"MO",@"MU",@"NA",@"NE",@"NI",@"NO",@"NU",@"PA",@"PE",@"PI",@"PO",@"PU",@"RA",@"RE",@"RI",@"RO",@"RU",@"SA",@"SE",@"SI",@"SO",@"SU",@"TA",@"TE",@"TI",@"TO",@"TU",@"VA",@"VE",@"VI",@"VO",@"VU"];
    phoeneticSoundsThree = @[@"BRA",@"BRE",@"BRI",@"BRO",@"BRU",@"BRY",@"DRA",@"DRE",@"DRI",@"DRO",@"DRU",@"DRY",@"FRA",@"FRE",@"FRI",@"FRO",@"FRU",@"FRY",@"GRA",@"GRE",@"GRI",@"GRO",@"GRU",@"GRY",@"PRA",@"PRE",@"PRI",@"PRO",@"PRU",@"PRY",@"STA",@"STE",@"STI",@"STO",@"STU",@"STY",@"TRA",@"TRE"];
    phoeneticSounds = [phoeneticSoundsTwo arrayByAddingObjectsFromArray:phoeneticSoundsThree];
    
    
    characterPattern = @{@"#" : @1, //Number
                         @"w" : @2, //Lowercase Word
                         @"W" : @3, //capital word
                         @"s" : @4, //lowercase short word
                         @"S" : @5, //capital short word
                         @"!" : @6, //symbol
                         @"c" : @7, //random character
                         @"C" : @8 //random uppercase char
                         };
    pronounceableSep = @{
                         @"Hyphen": @1,
                         @"Numbers" : @2,
                         @"None" : @3,
                         @"Symbols" : @4,
                         @"Characters" : @5,
                         @"Spaces"  : @6
                         };
    
}
/**
 *  Loads up our dictionary, and removes 'bad' words to generate pattern passwords.
 *  The results are cached so that the parsing only happens on app install or upgrade
 */
- (void)loadWords {
    //loading up our word list
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"frequency_lists" ofType:@"json"];
    NSString *badWordsPath = [[NSBundle mainBundle] pathForResource:@"bad_words" ofType:@"json"];

    NSString *englishWordsPath = [self getDocumentDirectory:@"englishWords.archive"];
    NSString *shortWordsPath = [self getDocumentDirectory:@"shortWords.archive"];
    NSString *wordsByLengthPath = [self getDocumentDirectory:@"wordsByLength.archive"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //Checking to see if our cached files exist and are newer than our data files, if so, load them instead of parsing
    if ([fileManager fileExistsAtPath:englishWordsPath] &&
        [fileManager fileExistsAtPath:shortWordsPath] &&
        [fileManager fileExistsAtPath:wordsByLengthPath]) {
        NSDate *eDate = [fileManager attributesOfItemAtPath:englishWordsPath error:nil][@"NSFileCreationDate"];
        NSDate *sDate = [fileManager attributesOfItemAtPath:shortWordsPath error:nil][@"NSFileCreationDate"];
        NSDate *wDate = [fileManager attributesOfItemAtPath:wordsByLengthPath error:nil][@"NSFileCreationDate"];
        NSDate *jDate = [fileManager attributesOfItemAtPath:jsonPath error:nil][@"NSFileCreationDate"];
        if ([eDate compare:jDate] == NSOrderedDescending && [sDate compare:jDate] == NSOrderedDescending && [wDate compare:jDate] == NSOrderedDescending) {
            self.englishWords = [NSKeyedUnarchiver unarchiveObjectWithFile:englishWordsPath];
            self.shortWords = [NSKeyedUnarchiver unarchiveObjectWithFile:shortWordsPath];
            self.wordsByLength = [NSKeyedUnarchiver unarchiveObjectWithFile:wordsByLengthPath];
        }
        if (self.englishWords.count > 0 && self.shortWords > 0 && self.wordsByLength.count > 0) {
            for (int i = 1; i < 15; i++) {
                if (self.wordsByLength[@(i)]) {
                    NSLog(@"%d : %lu",i,(unsigned long)[(NSArray*)self.wordsByLength[@(i)] count]);
                }
            }
            return;
        }
        
    }
    
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
    
    
}

/**
 *  Gets path to App document directory to allow saving of users and other data
 *
 *  @param withFile filename
 *
 *  @return path of file
 */
-(NSString *)getDocumentDirectory:(NSString *)withFile {
    NSArray *documentDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[documentDirs firstObject] stringByAppendingPathComponent:withFile];
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
 *  Removes duplicate characters from a string
 *
 *  @param input string to remove dupes
 *
 *  @return string without dupes
 */
- (NSMutableString *)removeDuplicateChars:(NSString *)input {
    
    NSMutableSet *seenCharacters = [NSMutableSet set];
    NSMutableString *result = [NSMutableString string];
    [input enumerateSubstringsInRange:NSMakeRange(0, input.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (![seenCharacters containsObject:substring]) {
            [seenCharacters addObject:substring];
            [result appendString:substring];
        }
    }];
    return result;
}

@end





