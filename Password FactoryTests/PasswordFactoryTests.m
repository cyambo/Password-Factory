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
#import "SecureRandom.h"
@interface Passsword_FactoryTests : XCTestCase
@property (nonatomic, strong) PasswordFactory *factory;
@end

@implementation Passsword_FactoryTests

- (void)setUp {
    [super setUp];
    self.factory = [PasswordFactory get];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)testGeneratePassphrase {

    self.factory.length = LONG_PASSWORD_LENGTH;
    NSDictionary *regexSep = @{
                            @(PFHyphenSeparator):@"-?",
                            @(PFSpaceSeparator):@"\\s?",
                            @(PFUnderscoreSeparator):@"_?",
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
            NSString *regex = [NSString stringWithFormat:@"(%@%@)+",regexCase[rCase],regexSep[rSeparator]];
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
                         return [self.factory generateRandom];
                     }];
    
    //testing mixed case

    [self regexCheckHasMatchesTest:@"[A-Z]"
                      errorMessage:@"Capitals found when mixedCase == NO"
                     generateBlock:^{
                         self.factory.caseType = PFLowerCase;
                         self.factory.avoidAmbiguous = NO;
                         self.factory.useSymbols = NO;
                         return [self.factory generateRandom];
                     }];
    
    //testing ambiguous characters

    [self regexCheckHasMatchesTest:@"[lo]"
                      errorMessage:@"Ambiguous Lowercase found when avoidAmbiguous = YES"
                     generateBlock:^{
                         self.factory.caseType = PFLowerCase;
                         self.factory.avoidAmbiguous = YES;
                         self.factory.useSymbols = NO;
                         return [self.factory generateRandom];
                     }];
    
    
    
}
- (void)testGeneratePattern {
    
    //testing single patterns
    
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
    //testing short word 's' pattern
    [self regexReplaceTest:@"^[a-z]{3,6}+$"
              errorMessage:@"Pattern 's' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"s"];
             }];
    //testing uppercase short word 'S' pattern
    [self regexReplaceTest:@"^[A-Z]{3,6}+$"
              errorMessage:@"Pattern 'S' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"S"];
             }];
    //testing symbol '!' pattern
    [self regexReplaceTest:@"^[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]$"
              errorMessage:@"Pattern '!' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"!"];
             }];
    
    //testing phonetic item 'p' pattern
    [self regexReplaceTest:@"^[a-z]{2,3}+$"
              errorMessage:@"Pattern 'p' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"p"];
             }];
    //testing phonetic uppercase item 'P' pattern
    [self regexReplaceTest:@"^[A-Z]{2,3}+$"
              errorMessage:@"Pattern 'P' failed"
             generateBlock:^{
                 return [self.factory generatePattern:@"P"];
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
//regular expression loop test
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
/**
 Test the random number generator
 */
-(void)testRandom {
    for (uint i = 1; i < 50; i ++) {
        for(uint j = 10; j < 20; j++) {
            uint k = [SecureRandom randomInt:j];
            XCTAssertFalse((k < 0 || k > j), @"Random Number is out of range");
        }
    }
}
@end
