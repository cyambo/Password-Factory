//
//  PasswordFactory.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordFactory : NSObject
@property (nonatomic, assign) NSUInteger passwordLength;
//These properties are only for random and pattern
//TODO: move to method ?



- (NSString *)generatePronounceableWithSeparatorType:(int)separatorType;
- (NSString *)generatePronounceable:(NSString *)separator;

- (NSString *)generateRandom:(BOOL)mixedCase avoidAmbiguous:(BOOL)avoidAmbiguous useSymbols:(BOOL)useSymbols;

- (NSString *)generatePattern: (NSString *)pattern;

- (NSString *)generatePassphrase:(NSString *)separator caseType:(int)caseType;
@end
