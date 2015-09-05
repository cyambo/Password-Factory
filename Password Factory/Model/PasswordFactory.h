//
//  PasswordFactory.h
//  Password Factory
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
@interface PasswordFactory : NSObject
@property (nonatomic, assign) NSUInteger passwordLength;

- (NSString *)generatePronounceableWithSeparatorType:(int)separatorType;
- (NSString *)generatePronounceable:(NSString *)separator;

- (NSString *)generateRandom:(BOOL)mixedCase avoidAmbiguous:(BOOL)avoidAmbiguous useSymbols:(BOOL)useSymbols;

- (NSString *)generatePattern: (NSString *)pattern;

- (NSString *)generatePassphrase:(NSString *)separator caseType:(int)caseType;
@end
