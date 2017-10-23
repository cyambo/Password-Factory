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

    self.pg.passwordLength = LONG_PASSWORD_LENGTH;
    NSDictionary *regexSep = @{
                            @PFPassphraseHyphenSeparator:@"-?",
                            @PFPassphraseSpaceSeparator:@"\\s?",
                            @PFPassphraseUnderscoreSeparator:@"_?",
                            @PFPassphraseNoSeparator:@"",

                           };
    NSDictionary *regexCase = @{

                             @PFPassphraseLowerCase:@"[a-z]+",
                             @PFPassphraseTitleCase:@"[A-Z][a-z]+",
                             @PFPassphraseUpperCase:@"[A-Z]+",
                             @PFPassphraseMixedCase:@"[a-zA-Z]"
                             };
    for (NSNumber *rSeparator in [regexSep allKeys]) {
        for(NSNumber *rCase in [regexCase allKeys]) {
            NSString *regex = [NSString stringWithFormat:@"(%@%@)+",regexCase[rCase],regexSep[rSeparator]];
            NSString *errorMessage = [NSString stringWithFormat:@"Regex %@ failed for generatePassphhrase:%@:%@",regex,rSeparator,rCase];
            
            [self regexReplaceTest:regex errorMessage:errorMessage generateBlock:^NSString *{
                return [self.pg generatePassphraseWithCode:[rSeparator intValue] caseType:[rCase intValue]];
            }];
        }
    }
 

                              
                             
}
- (void)testGeneratePronounceable {
    self.pg.passwordLength = LONG_PASSWORD_LENGTH;
    
    [self regexReplaceTest:@"([a-z]+-?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Hyphen"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFPronounceableHyphenSeparator];
             }];
    [self regexReplaceTest:@"[a-z]"
              errorMessage:@"Value of password not valid for generatePronounceable:None"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFPronounceableNoSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+[A-Z]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Characters"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFPronounceableCharacterSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+[0-9]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Numbers"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFPronounceableNumberSeparator];
             }];
    
    [self regexReplaceTest:@"([a-z]+[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Symbols"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFPronounceableSymbolSeparator];
             }];
    [self regexReplaceTest:@"([a-z]+ ?)+"
              errorMessage:@"Value of password not valid for generatePronounceable:Spaces"
             generateBlock:^{
                 return [self.pg generatePronounceableWithSeparatorType:PFPronounceableSpaceSeparator];
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
    self.pg.passwordLength = 5;
    XCTAssertTrue([self.pg generateRandom:YES avoidAmbiguous:YES useSymbols:YES].length == 5, @"Password Length not 5");
    self.pg.passwordLength = 10;
    XCTAssertFalse([self.pg generateRandom:YES avoidAmbiguous:YES useSymbols:YES].length == 5, @"Password Length not Changed from 5 to 10");
    XCTAssertTrue([self.pg generateRandom:YES avoidAmbiguous:YES useSymbols:YES].length == 10, @"Password Length not 10");
    
    self.pg.passwordLength = LONG_PASSWORD_LENGTH;
    //testing the useSymbols to see if any symbols are part of the password

    
    
    [self regexCheckHasMatchesTest:@"[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]"
                      errorMessage:@"Symbol found when useSymbols == NO"
                     generateBlock:^{
                         return [self.pg generateRandom:YES avoidAmbiguous:YES useSymbols:NO];
                     }];
    
    //testing mixed case

    [self regexCheckHasMatchesTest:@"[A-Z]"
                      errorMessage:@"Capitals found when mixedCase == NO"
                     generateBlock:^{
                         return [self.pg generateRandom:NO avoidAmbiguous:NO useSymbols:NO];
                     }];
    
    //testing ambiguous characters

    [self regexCheckHasMatchesTest:@"[lo]"
                      errorMessage:@"Ambiguous Lowercase found when avoidAmbiguous = YES"
                     generateBlock:^{
                         return [self.pg generateRandom:NO avoidAmbiguous:YES useSymbols:NO];
                     }];
    
    
    
}
- (void)testGeneratePattern {
    
    //testing single patterns
    [self regexReplaceTest:@"^[a-z]$"
              errorMessage:@"Pattern 'c' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"c"];
             }];
    [self regexReplaceTest:@"^[A-Z]$"
              errorMessage:@"Pattern 'C' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"C"];
             }];
    [self regexReplaceTest:@"^[0-9]$"
              errorMessage:@"Pattern '#' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"#"];
             }];
    [self regexReplaceTest:@"^[a-z]+$"
              errorMessage:@"Pattern 'w' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"w"];
             }];
    [self regexReplaceTest:@"^[A-Z]+$"
              errorMessage:@"Pattern 'W' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"W"];
             }];
    [self regexReplaceTest:@"^[a-z]{3,6}+$"
              errorMessage:@"Pattern 's' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"s"];
             }];
    [self regexReplaceTest:@"^[A-Z]{3,6}+$"
              errorMessage:@"Pattern 'S' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"S"];
             }];
    [self regexReplaceTest:@"^[!@#$%^&*(){};:.<>?/'_+=|\\-\\[\\]\\\"\\\\]$"
              errorMessage:@"Pattern '!' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"!"];
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
    [self regexReplaceTest:@"^dDEe>$"
              errorMessage:@"Pattern 'dDEe>' failed"
             generateBlock:^{
                 return [self.pg generatePattern:@"dDEe>"];
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
