//
//  PasswordGenerator.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "PasswordGenerator.h"


static NSString* symbols;
static NSString* upperCase;
static NSString* lowerCase;
static NSString* nonAmbiguousUpperCase;
static NSString* nonAmbiguousLowerCase;
static NSDictionary* characterPattern;
static NSArray* phoeneticSounds;
static NSArray* phoeneticSoundsTwo;
static NSArray* phoeneticSoundsThree;
static NSDictionary* pronounceableSep;


@interface PasswordGenerator ()
@property (nonatomic, strong) NSMutableString *currentRange;

@property (nonatomic, strong) NSArray *englishWords;
@property (nonatomic, strong) NSArray *shortWords;
@end

@implementation PasswordGenerator
- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [self loadJSONDict];
        [self setStatics];
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
            if (w.length > 4 && w.length < 10) {
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
- (char)getPronounceableSeparator:(NSString *)selectedTitle {
    char sep = ' ';
    switch ((int)[[pronounceableSep objectForKey:selectedTitle] integerValue]) {
        case 1:
            sep = ' ';
            break;
        case 2:
            sep = '-';
            break;
        case 3:
            sep = [self randomFromString:nonAmbiguousUpperCase];
            break;
        case 4:
            sep = [[NSString stringWithFormat:@"%d",arc4random()%10] characterAtIndex:0];
            break;
        case 5:
            sep = [self randomFromString:symbols];
            break;
        default:
            sep = ' ';
            break;
    }
    return sep;
}
- (NSString *)generatePronounceable:(NSString *)selectedTitle {

    NSMutableString *p = [[NSMutableString alloc] init];
    char sep = [self getPronounceableSeparator:selectedTitle];

    while (p.length < self.passwordLength) {
        NSString *append = [[self getPronounceableForLength:(self.passwordLength - (int)p.length)] lowercaseString];
        if ([append isEqual: @""]) {
            break;
        } else {
            [p appendString:append];
        }
        if (p.length < self.passwordLength) {
            if (sep != ' ') {
                [p appendString:[NSString stringWithFormat:@"%c",sep]];
            }
        }
        
    }
    
    return p;
    
}
- (NSString *)getPronounceableForLength:(int)length {
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
    } else {
        [tmp appendString:lowerCase];
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
    phoeneticSoundsTwo = @[@"BA",@"BE",@"BI",@"BO",@"BU",@"BY",@"DA",@"DE",@"DI",@"DO",@"DU",@"DY",@"FA",@"FE",@"FI",@"FO",@"FU",@"FY",@"GA",@"GE",@"GI",@"GO",@"GU",@"GY",@"HA",@"HE",@"HI",@"HO",@"HU",@"HY",@"JA",@"JE",@"JI",@"JO",@"JU",@"JY",@"KA",@"KE",@"KI",@"KO",@"KU",@"KY",@"LA",@"LE",@"LI",@"LO",@"LU",@"LY",@"MA",@"ME",@"MI",@"MO",@"MU",@"MY",@"NA",@"NE",@"NI",@"NO",@"NU",@"NY",@"PA",@"PE",@"PI",@"PO",@"PU",@"PY",@"RA",@"RE",@"RI",@"RO",@"RU",@"RY",@"SA",@"SE",@"SI",@"SO",@"SU",@"SY",@"TA",@"TE",@"TI",@"TO",@"TU",@"TY",@"VA",@"VE",@"VI",@"VO",@"VU",@"VY"];
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
                         @"Symbols" : @5
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





