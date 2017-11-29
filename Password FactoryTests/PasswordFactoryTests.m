//
//  Passsword_GeneratorTests.m
//  Passsword GeneratorTests
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

const int RANDOM_ITERATIONS = 20;
const int LONG_PASSWORD_LENGTH = 100;
#import <XCTest/XCTest.h>
#import "PasswordFactory.h"
#import "Utilities.h"
@interface Passsword_FactoryTests : XCTestCase
@property (nonatomic, strong) PasswordFactory *factory;
@end

@implementation Passsword_FactoryTests

- (void)setUp {
    [super setUp];
    self.factory = [PasswordFactory get];
}

- (void)tearDown {
    [super tearDown];
}
- (void)testGeneratePassphrase {

    self.factory.length = LONG_PASSWORD_LENGTH;
    NSDictionary *regexSep = @{
                            @(PFHyphenSeparator):@"-?",
                            @(PFSpaceSeparator):@"\\s?",
                            @(PFUnderscoreSeparator):@"_?",
                            @(PFNumberSeparator):@"[0-9]",
                            @(PFSymbolSeparator):@"[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]",
                            @(PFCharacterSeparator):@"[A-Za-z]",
                            @(PFRandomSeparator):@".",
                            @(PFNoSeparator):@"",

                           };
    NSDictionary *regexCase = @{

                             @(PFLowerCase):@"[a-z]+",
                             @(PFTitleCase):@"[A-Z][a-z]+",
                             @(PFUpperCase):@"[A-Z]+",
                             @(PFMixedCase):@"[a-zA-Z]"
                             };
    for (NSNumber *rSeparator in [regexSep allKeys]) {
        for(NSNumber *rCase in [regexCase allKeys]) {
            NSString *regex = [NSString stringWithFormat:@"^(%@%@?)+$",regexCase[rCase],regexSep[rSeparator]];
            NSString *errorMessage = [NSString stringWithFormat:@"Regex %@ failed for generatePassphhrase:%@:%@",regex,rSeparator,rCase];
            
            [self regexReplaceTest:regex errorMessage:errorMessage generateBlock:^NSString *{
                self.factory.caseType = (PFCaseType)[rCase intValue];
                return [self.factory generatePassphraseWithSeparatorType:(PFSeparatorType)[rSeparator intValue]];
            }];
        }
    }
}

- (void)testGeneratePronounceable {
    self.factory.length = LONG_PASSWORD_LENGTH;
    self.factory.caseType = PFLowerCase;
    [self regexReplaceTest:@"([a-z]+-?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Hyphen"
             generateBlock:^{
                 return [self.factory generatePronounceableWithSeparatorType:PFHyphenSeparator];
             }];
    [self regexReplaceTest:@"[a-z]"
              errorMessage:@"Value of password not valid for generatePronounceable:None"
             generateBlock:^{
                 return [self.factory generatePronounceableWithSeparatorType:PFNoSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+[A-Z]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Characters"
             generateBlock:^{
                 return [self.factory generatePronounceableWithSeparatorType:PFCharacterSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+[0-9]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Numbers"
             generateBlock:^{
                 return [self.factory generatePronounceableWithSeparatorType:PFNumberSeparator];
             }];
    
    [self regexReplaceTest:@"([a-z]+[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Symbols"
             generateBlock:^{
                 return [self.factory generatePronounceableWithSeparatorType:PFSymbolSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+ ?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Spaces"
             generateBlock:^{
                 return [self.factory generatePronounceableWithSeparatorType:PFSpaceSeparator];
             }];
    
    
}

- (void)testGenerateRandom {
    
    //testing password lengths
    self.factory.length = 5;
    self.factory.caseType = PFMixedCase;
    self.factory.avoidAmbiguous = YES;
    self.factory.useSymbols = YES;
    self.factory.useEmoji = NO;
    self.factory.useNumbers = NO;
    XCTAssertTrue([self.factory generateRandom].length == 5, @"Password Length not 5");
    self.factory.length = 10;
    XCTAssertFalse([self.factory generateRandom].length == 5, @"Password Length not Changed from 5 to 10");
    XCTAssertTrue([self.factory generateRandom].length == 10, @"Password Length not 10");
    
    self.factory.length = LONG_PASSWORD_LENGTH;
    //testing the useSymbols to see if any symbols are part of the password
    [self regexCheckHasMatchesTest:@"[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]"
                      errorMessage:@"Symbol found when useSymbols == NO"
                     generateBlock:^{
                         self.factory.caseType = PFMixedCase;
                         self.factory.avoidAmbiguous = YES;
                         self.factory.useSymbols = NO;
                         self.factory.useNumbers = NO;
                         return [self.factory generateRandom];
                     }];
    
    //testing lower case
    [self regexCheckHasMatchesTest:@"[A-Z]"
                      errorMessage:@"Capitals found when mixedCase == NO"
                     generateBlock:^{
                         self.factory.caseType = PFLowerCase;
                         self.factory.avoidAmbiguous = NO;
                         self.factory.useSymbols = NO;
                         self.factory.useNumbers = NO;
                         return [self.factory generateRandom];
                     }];
    
    //testing ambiguous characters
    [self regexCheckHasMatchesTest:@"[lo]"
                      errorMessage:@"Ambiguous Lowercase found when avoidAmbiguous = YES"
                     generateBlock:^{
                         self.factory.caseType = PFLowerCase;
                         self.factory.avoidAmbiguous = YES;
                         self.factory.useSymbols = NO;
                         self.factory.useNumbers = NO;
                         return [self.factory generateRandom];
                     }];
    //checking uppercase
    [self regexCheckHasMatchesTest:@"[a-z]"
                      errorMessage:@"Lowercase found when PFUpperCase"
                     generateBlock:^{
                         self.factory.caseType = PFUpperCase;
                         self.factory.avoidAmbiguous = NO;
                         self.factory.useSymbols = NO;
                         self.factory.useNumbers = NO;
                         return [self.factory generateRandom];
                     }];
    //checking numbers - no
    [self regexCheckHasMatchesTest:@"[0-9]"
                      errorMessage:@"Number found when useNumbers == NO"
                     generateBlock:^{
                         self.factory.caseType = PFUpperCase;
                         self.factory.avoidAmbiguous = NO;
                         self.factory.useSymbols = NO;
                         self.factory.useNumbers = NO;
                         return [self.factory generateRandom];
                     }];
    //checking numbers - yes
    [self regexCheckHasMatchesTest:@"[^A-Z0-9]"
                      errorMessage:@"Numbers should be found"
                     generateBlock:^{
                         self.factory.caseType = PFUpperCase;
                         self.factory.avoidAmbiguous = NO;
                         self.factory.useSymbols = NO;
                         self.factory.useNumbers = YES;
                         return [self.factory generateRandom];
                     }];
    
}
- (void)testGeneratePattern {
    
    //testing single patterns
    //Testing Number '#' pattern
    [self regexReplaceTest:@"^[0-9]$"
              errorMessage:@"Pattern '#' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"#"];
             }];
    //Testing Word 'w' pattern
    [self regexReplaceTest:@"^[a-z]+$"
              errorMessage:@"Pattern 'w' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"w"];
             }];
    //Testing uppercase word 'W' pattern
    [self regexReplaceTest:@"^[A-Z]+$"
              errorMessage:@"Pattern 'W' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"W"];
             }];
    //Testing random case word 'd' pattern
    [self regexReplaceTest:@"^[A-Za-z]+$"
              errorMessage:@"Pattern 'd' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"d"];
             }];
    //Testing title case word 'D' pattern
    [self regexReplaceTest:@"^[A-Z][a-z]+$"
              errorMessage:@"Pattern 'D' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"D"];
             }];
    //testing short word 's' pattern
    [self regexReplaceTest:@"^[a-z]{3,6}+$"
              errorMessage:@"Pattern 's' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"s"];
             }];
    //testing uppercase short word 'S' pattern
    [self regexReplaceTest:@"^[A-Z]{3,6}$"
              errorMessage:@"Pattern 'S' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"S"];
             }];
    
    //Testing random case short word 'h' pattern
    [self regexReplaceTest:@"^[A-Za-z]{3,6}$"
              errorMessage:@"Pattern 'h' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"h"];
             }];
    //Testing title case short word 'H' pattern
    [self regexReplaceTest:@"^[A-Z][a-z]{2-5}$"
              errorMessage:@"Pattern 'H' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"H"];
             }];
    //testing symbol '!' pattern
    [self regexReplaceTest:@"^[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]$"
              errorMessage:@"Pattern '!' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"!"];
             }];
    //Testing Character 'c' pattern
    [self regexReplaceTest:@"^[a-z]$"
              errorMessage:@"Pattern 'c' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"c"];
             }];
    //Testing Uppercase Character 'C' pattern
    [self regexReplaceTest:@"^[A-Z]$"
              errorMessage:@"Pattern 'C' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"C"];
             }];

    //Testing non ambiguous Character 'a' pattern
    [self regexReplaceTest:@"^[abcdefghijkmnpqrstuvwxyz]$"
              errorMessage:@"Pattern 'a' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"a"];
             }];
    //Testing non-ambiguous Uppercase Character 'A' pattern
    [self regexReplaceTest:@"^[ABCDEFGHJKLMNPQRSTUVWXYZ]$"
              errorMessage:@"Pattern 'a' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"A"];
             }];
    //Testing non-ambiguous number 'N' pattern
    [self regexReplaceTest:@"^[23456789]$"
              errorMessage:@"Pattern 'N' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"N"];
             }];

    
    //testing phonetic item 'p' pattern
    [self regexReplaceTest:@"^[a-z]{2,3}$"
              errorMessage:@"Pattern 'p' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"p"];
             }];
    //testing uppercase phonetic item 'P' pattern
    [self regexReplaceTest:@"^[A-Z]{2,3}$"
              errorMessage:@"Pattern 'P' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"P"];
             }];
    //testing random case phonetic item 't' pattern
    [self regexReplaceTest:@"^[a-zA-Z]{2,3}$"
              errorMessage:@"Pattern 't' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"t"];
             }];
    //testing title case phonetic item 'T' pattern
    [self regexReplaceTest:@"^[A-Z][a-z]{1,2}$"
              errorMessage:@"Pattern 'T' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"T"];
             }];
    //testing random item 'r' pattern
    [self regexReplaceTest:@"^[a-z]$"
              errorMessage:@"Pattern 'r' failed"
             generateBlock:^{
                 self.factory.useNumbers = NO;
                 self.factory.useSymbols = NO;
                 self.factory.useEmoji = NO;
                 self.factory.caseType = PFLowerCase;
                 return [self.factory generatePattern:@"r"];
             }];
    //testing multiple patterns
    [self regexReplaceTest:@"^[a-z][A-Z]$"
              errorMessage:@"Pattern 'cC' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"cC"];
             }];
    [self regexReplaceTest:@"^[A-Z][0-9]{2}$"
              errorMessage:@"Pattern 'C##' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"C##"];
             }];
    [self regexReplaceTest:@"^[A-Z]+[a-z]+[A-Z][a-z]$"
              errorMessage:@"Pattern 'WwCc' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"WwCc"];
             }];
    
    //testing escapes
    [self regexReplaceTest:@"^C$"
              errorMessage:@"Pattern '\\C' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"\\C"];
             }];
    //testing character replacement
    [self regexReplaceTest:@"^nQYy>$"
              errorMessage:@"Pattern 'nQYy>' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"nQYy>"];
             }];
    
}
-(void)testTransformPasswordRegexReplace {
    NSError *error;
    NSString *regexPattern = @".";
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:regexPattern
                                  options:0
                                  error:&error
                                  ];
    NSString *password = @"123abc!@#";
    self.factory.find = regex;
    self.factory.replace = @"-";
    self.factory.truncate = 0;
    self.factory.prefix = nil;
    self.factory.suffix = nil;
    NSString *t = [self.factory transformPassword:password symbolCasePrecent:0 accentedCasePercent:0];
    XCTAssertTrue(t.length == password.length,@"Transformed password should match length");
    t = [t stringByReplacingOccurrencesOfString:@"-" withString:@""];
    XCTAssertTrue(t.length == 0, @"Transformed password should only contain dashes (-)");
}
-(void)testTransformPasswordPrefixSuffix {
    NSString *password = @"";
    self.factory.find = nil;
    self.factory.replace = nil;
    self.factory.prefix = @"W-";
    self.factory.suffix = @"-#";
    self.factory.truncate = 0;
    NSString *t = [self.factory transformPassword:password symbolCasePrecent:0 accentedCasePercent:0];
    XCTAssertTrue([t isEqualToString:@"W--#"],@"Prefix and suffix should be added");
}
-(void)testTransformPasswordAccentedCase {
    NSString *password = @"password";
    self.factory.find = nil;
    self.factory.replace = nil;
    self.factory.prefix = nil;
    self.factory.suffix = nil;
    self.factory.truncate = 0;
    NSString *t = [self.factory transformPassword:password symbolCasePrecent:0 accentedCasePercent:100];
    XCTAssertTrue(t.length == password.length, @"Lengths should be equal");
    XCTAssertFalse([t isEqualToString:password], @"Passwords should not be equal");
    [self regexReplaceTest:@"^[^a-zA-Z]+$" errorMessage:@"Password should only contain accented characters" generateBlock:^NSString *{
        return [self.factory transformPassword:password symbolCasePrecent:0 accentedCasePercent:100];
    }];
}
-(void)testTransformPasswordSymbolCase {
    NSString *password = @"password";
    self.factory.find = nil;
    self.factory.replace = nil;
    self.factory.prefix = nil;
    self.factory.suffix = nil;
    self.factory.truncate = 0;
    for(int i = 0; i < RANDOM_ITERATIONS; i++) {
        NSString *t = [self.factory transformPassword:password symbolCasePrecent:100 accentedCasePercent:0];
        XCTAssertFalse(password.length == t.length, @"Password length should not match");
    }
}
-(void)testTransformPasswordTruncate {
    NSString *password = @"password";
    self.factory.find = nil;
    self.factory.replace = nil;
    self.factory.prefix = @"PREFIX";
    self.factory.suffix = @"SUFFIX";
    self.factory.truncate = 1;
    NSString *t = [self.factory transformPassword:password symbolCasePrecent:100 accentedCasePercent:100];
    XCTAssertTrue(t.length == 1, @"Password length should be one");
}
-(void)testTransformPasswordReplaceAmbiguous {
    NSString *password = @"IOlo";
    self.factory.find = nil;
    self.factory.replace = nil;
    self.factory.prefix = nil;
    self.factory.suffix = nil;
    self.factory.truncate = 0;
    self.factory.replaceAmbiguous = YES;
    self.factory.caseType = 0;
    NSString *t = [self.factory transformPassword:password symbolCasePrecent:0 accentedCasePercent:0];
    self.factory.replaceAmbiguous = NO;
    XCTAssertTrue([t isEqualToString:@"1010"],@"Ambiguous characters should have been replaced");
}
/**
 Test the random number generator
 */
-(void)testRandomNumberGenerator {
    for (uint i = 1; i < RANDOM_ITERATIONS; i ++) {
        for(uint j = 10; j < 20; j++) {
            uint k = [Utilities randomInt:j];
            XCTAssertFalse((k < 0 || k > j), @"Random Number is out of range");
        }
    }
}

/**
 Checks to see if the regex has any matches, if so it fails

 @param regexPattern Regex Pattern
 @param errorMessage Error Message
 @param generateBlock block to generate password
 */
- (void)regexCheckHasMatchesTest: (NSString *)regexPattern
                    errorMessage:(NSString *)errorMessage
                   generateBlock:(NSString *(^)(void))generateBlock {
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:regexPattern
                                  options:0
                                  error:&error
                                  ];
    for (int i = 0; i < RANDOM_ITERATIONS; i++) {
        NSString *curr = generateBlock();
        NSArray *matches = [regex matchesInString:curr
                                          options:0
                                            range:NSMakeRange(0, curr.length)
                            ];
        XCTAssertTrue(matches.count == 0, @"%@ -'%@'",errorMessage,curr);
        
    }
}

/**
 Uses a regex to match all characters in password, if any are remaining the test fails

 @param regexPattern regex to use
 @param errorMessage error message to display
 @param generateBlock block to generate password
 */
- (void)regexReplaceTest: (NSString *)regexPattern
            errorMessage: (NSString *)errorMessage
           generateBlock: (NSString *(^)(void))generateBlock {
    NSError *error;
    NSRegularExpression *replaceRegex = [NSRegularExpression
                                         regularExpressionWithPattern:regexPattern
                                         options:0
                                         error:&error];
    for (int i = 0; i < RANDOM_ITERATIONS; i++) {
        NSString *curr  = generateBlock();
        NSString *r = [replaceRegex stringByReplacingMatchesInString:curr
                                                             options:0
                                                               range:NSMakeRange(0, curr.length)
                                                        withTemplate:@""];
        
        XCTAssertTrue(r.length == 0, @"%@ - '%@'",errorMessage,curr);
    }
}

@end
