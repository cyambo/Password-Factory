//
//  PasswordFactory.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
@interface PasswordFactory : NSObject
@property (nonatomic, assign) NSUInteger passwordLength;

- (NSString *)generatePronounceableWithSeparatorType:(int)separatorType;
- (NSString *)generatePronounceable:(NSString *)separator;

- (NSString *)generateRandom:(BOOL)mixedCase avoidAmbiguous:(BOOL)avoidAmbiguous useSymbols:(BOOL)useSymbols;

- (NSString *)generatePattern: (NSString *)pattern;
-(NSString *)generatePatternWithOptions: (NSString *)pattern mixedCase:(BOOL)mixedCase avoidAmbiguous:(BOOL)avoidAmbiguous useSymbols:(BOOL)useSymbols;
- (NSString *)generatePassphrase:(NSString *)separator caseType:(int)caseType;
- (NSString *)generatePassphraseWithSeparatorCode:(int)separatorCode caseType:(int)caseType;
- (uint)randomNumber:(uint)limit;
- (NSString *)getPasswordBuilderItem:(NSString *)item;
- (BOOL)characterIsTypeOfPasswordBuilderItem:(NSString *)type character:(NSString *)character;
@end
