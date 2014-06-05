//
//  PasswordFactory.m
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "PasswordFactory.h"


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
@end

@implementation PasswordFactory
- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [self loadJSONDict];
        [self setStatics];
        self.useSymbols = YES;
        self.avoidAmbiguous = YES;
        self.mixedCase = YES;
        self.passwordLength = 5;
        
    }
    return self;
}
- (void)loadJSONDict {
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"frequency_lists" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *dicts = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSMutableArray *e = [[NSMutableArray alloc] init];
    NSMutableArray *es = [[NSMutableArray alloc] init];
    NSCharacterSet *charSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    for (NSString *w in [dicts objectForKey:@"english"]) {
        
        if ([w rangeOfCharacterFromSet:charSet].length == 0){
            if (w.length > 6) {
                [e addObject:w];
            }
            if (w.length > 3 && w.length < 6) {
                [es addObject:w];
            }
        }
        
    }
    
    self.englishWords = [[NSArray alloc] initWithArray:e];
    self.shortWords = [[NSArray alloc] initWithArray:es];
    
}
- (char)randomFromString:(NSString *)source {
    return [source characterAtIndex:(arc4random() % source.length)];
}
- (id)randomFromArray:(NSArray *)source {
    return [source objectAtIndex:(arc4random() % source.count)];
}
- (NSString *)getPronounceableSeparator:(NSString *)selectedTitle {
    NSString *sep = @"";
    switch ((int)[[pronounceableSep objectForKey:selectedTitle] integerValue]) {
        case 1:
            sep = @"";
            break;
        case 2:
            sep = @"-";
            break;
        case 3:
            sep = [NSString stringWithFormat:@"%c",[self randomFromString:nonAmbiguousUpperCase]];
            break;
        case 4:
            sep = [NSString stringWithFormat:@"%d",arc4random()%10];
            break;
        case 5:
            sep = [NSString stringWithFormat:@"%c",[self randomFromString:symbols]];
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
- (NSString *)generatePronounceable:(NSString *)selectedTitle {

    NSMutableString *p = [[NSMutableString alloc] init];
    NSString *sep = [self getPronounceableSeparator:selectedTitle];
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
        if (isEscaped ){
            [s appendString:[NSString stringWithFormat:@"%c",c]];
            isEscaped = NO;
            continue;
        }
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
                         @"None": @1,
                         @"Hyphen" : @2,
                         @"Characters" : @3,
                         @"Numbers" : @4,
                         @"Symbols" : @5,
                         @"Spaces"  : @6
                         };
    
}
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





