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
@interface Passsword_FactoryTests : XCTestCase
@property (nonatomic, strong) PasswordFactory *pg;
@end

@implementation Passsword_FactoryTests

- (void)setUp {
    [super setUp];
    self.pg = [[PasswordFactory alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)testGeneratePassphrase {

    self.pg.length = LONG_PASSWORD_LENGTH;
    NSDictionary *regexSep = @{
                            @(PFHyphenSeparator):@"-?",
                            @(PFSpaceSeparator):@"\\s?",
                            @(PFUnderscoreSeparator):@"_?",
                            @(PFNoSeparator):@"",

                           };
    NSDictionary *regexCase = @{

                             @(PFLower):@"[a-z]+",
                             @(PFTitle):@"[A-Z][a-z]+",
                             @(PFUpper):@"[A-Z]+",
                             @(PFMixed):@"[a-zA-Z]"
                             };
    for (NSNumber *rSeparator in [regexSep allKeys]) {
        for(NSNumber *rCase in [regexCase allKeys]) {
            NSString *regex = [NSString stringWithFormat:@"(%@%@)+",regexCase[rCase],regexSep[rSeparator]];
            NSString *errorMessage = [NSString stringWithFormat:@"Regex %@ failed for generatePassphhrase:%@:%@",regex,rSeparator,rCase];
            
            [self regexReplaceTest:regex errorMessage:errorMessage generateBlock:^NSString *{
                self.pg.caseType = (PFCaseType)[rCase intValue];
                return [self.pg generatePassphraseWithSeparatorType:(PFSeparatorType)[rSeparator intValue]];
            }];
        }
    }
}

- (void)testGeneratePronounceable {
    self.pg.length = LONG_PASSWORD_LENGTH;
    self.pg.caseType = PFLower;
    [self regexReplaceTest:@"([a-z]+-?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Hyphen"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFHyphenSeparator];
             }];
    [self regexReplaceTest:@"[a-z]"
              errorMessage:@"Value of password not valid for generatePronounceable:None"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFNoSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+[A-Z]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Characters"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFCharacterSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+[0-9]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Numbers"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFNumberSeparator];
             }];
    
    [self regexReplaceTest:@"([a-z]+[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Symbols"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFSymbolSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+ ?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Spaces"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFSpaceSeparator];
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
- (void)testGenerateRandom {
    
    //testing password lengths
    self.pg.length = 5;
    self.pg.caseType = PFMixed;
    self.pg.avoidAmbiguous = YES;
    self.pg.useSymbols = YES;
    XCTAssertTrue([self.pg generateRandom].length == 5, @"Password Length not 5");
    self.pg.length = 10;
    XCTAssertFalse([self.pg generateRandom].length == 5, @"Password Length not Changed from 5 to 10");
    XCTAssertTrue([self.pg generateRandom].length == 10, @"Password Length not 10");
    
    self.pg.length = LONG_PASSWORD_LENGTH;
    //testing the useSymbols to see if any symbols are part of the password

    
    
    [self regexCheckHasMatchesTest:@"[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]"
                      errorMessage:@"Symbol found when useSymbols == NO"
                     generateBlock:^{
                         self.pg.caseType = PFMixed;
                         self.pg.avoidAmbiguous = YES;
                         self.pg.useSymbols = NO;
                         return [self.pg generateRandom];
                     }];
    
    //testing mixed case

    [self regexCheckHasMatchesTest:@"[A-Z]"
                      errorMessage:@"Capitals found when mixedCase == NO"
                     generateBlock:^{
                         self.pg.caseType = PFLower;
                         self.pg.avoidAmbiguous = NO;
                         self.pg.useSymbols = NO;
                         return [self.pg generateRandom];
                     }];
    
    //testing ambiguous characters

    [self regexCheckHasMatchesTest:@"[lo]"
                      errorMessage:@"Ambiguous Lowercase found when avoidAmbiguous = YES"
                     generateBlock:^{
                         self.pg.caseType = PFLower;
                         self.pg.avoidAmbiguous = YES;
                         self.pg.useSymbols = NO;
                         return [self.pg generateRandom];
                     }];
    
    
    
}
- (void)testGeneratePattern {
    
    //testing single patterns
    
    //Testing Character 'c' pattern
    [self regexReplaceTest:@"^[a-z]$"
              errorMessage:@"Pattern 'c' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"c"];
             }];
    //Testing Uppercase Character 'C' pattern
    [self regexReplaceTest:@"^[A-Z]$"
              errorMessage:@"Pattern 'C' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"C"];
             }];
    //Testing Number '#' pattern
    [self regexReplaceTest:@"^[0-9]$"
              errorMessage:@"Pattern '#' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"#"];
             }];
    //Testing Word 'w' pattern
    [self regexReplaceTest:@"^[a-z]+$"
              errorMessage:@"Pattern 'w' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"w"];
             }];
    //Testing uppercase word 'W' pattern
    [self regexReplaceTest:@"^[A-Z]+$"
              errorMessage:@"Pattern 'W' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"W"];
             }];
    //testing short word 's' pattern
    [self regexReplaceTest:@"^[a-z]{3,6}+$"
              errorMessage:@"Pattern 's' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"s"];
             }];
    //testing uppercase short word 'S' pattern
    [self regexReplaceTest:@"^[A-Z]{3,6}+$"
              errorMessage:@"Pattern 'S' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"S"];
             }];
    //testing symbol '!' pattern
    [self regexReplaceTest:@"^[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]$"
              errorMessage:@"Pattern '!' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"!"];
             }];
    
    //testing phonetic item 'p' pattern
    [self regexReplaceTest:@"^[a-z]{2,3}+$"
              errorMessage:@"Pattern 'p' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"p"];
             }];
    //testing phonetic uppercase item 'P' pattern
    [self regexReplaceTest:@"^[A-Z]{2,3}+$"
              errorMessage:@"Pattern 'P' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"P"];
             }];
    
    //testing multiple patterns
    [self regexReplaceTest:@"^[a-z][A-Z]$"
              errorMessage:@"Pattern 'cC' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"cC"];
             }];
    [self regexReplaceTest:@"^[A-Z][0-9]{2}$"
              errorMessage:@"Pattern 'C##' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"C##"];
             }];
    [self regexReplaceTest:@"^[A-Z]+[a-z]+[A-Z][a-z]$"
              errorMessage:@"Pattern 'WwCc' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"WwCc"];
             }];
    
    //testing escapes
    [self regexReplaceTest:@"^C$"
              errorMessage:@"Pattern '\\C' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"\\C"];
             }];
    //testing character replacement
    [self regexReplaceTest:@"^dDYy>$"
              errorMessage:@"Pattern 'dDYy>' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"dDYy>"];
             }];
    
}

/**
 Test the random number generator
 */
-(void)testRandom {
    for (uint i = 1; i < 50; i ++) {
        for(uint j = 10; j < 20; j++) {
            uint k = [self.pg randomNumber:j];
            XCTAssertFalse((k < 0 || k > j), @"Random Number is out of range");
        }
    }
}
@end
