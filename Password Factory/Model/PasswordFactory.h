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

@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign) PFCaseType caseType;
@property (nonatomic, assign) BOOL avoidAmbiguous;
@property (nonatomic, assign) BOOL replaceAmbiguous;
@property (nonatomic, assign) BOOL useSymbols;
@property (nonatomic, assign) BOOL useEmoji;
@property (nonatomic, assign) BOOL useNumbers;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *postfix;
@property (nonatomic, strong) NSRegularExpression *find;
@property (nonatomic, strong) NSString *replace;
@property (nonatomic, assign) NSUInteger truncate;

+ (instancetype)get;
- (NSString *)generatePronounceableWithSeparatorType:(PFSeparatorType)separatorType;
- (NSString *)generatePronounceable;
- (NSString *)generateRandom;
- (NSString *)generatePattern:(NSString *)pattern;
- (NSString *)generatePassphrase;
- (NSString *)generatePassphraseWithSeparatorType:(PFSeparatorType)separatorType;
- (NSString *)transformPassword:(NSString *)source symbolCasePrecent:(NSUInteger)symbol accentedCasePercent:(NSUInteger)accent;
- (uint)randomNumber:(uint)limit;
- (NSString *)getPasswordCharacterType:(PFCharacterType)type;
- (BOOL)isCharacterType:(PFCharacterType)type character:(NSString *)character;
@end
