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
@property (nonatomic, strong) NSString *separator;
@property (nonatomic, assign) PFCaseType caseType;
@property (nonatomic, assign) BOOL avoidAmbiguous;
@property (nonatomic, assign) BOOL useSymbols;
@property (nonatomic, assign) BOOL useEmoji;

- (NSString *)generatePronounceableWithSeparatorType:(PFSeparatorType)separatorType;
- (NSString *)generatePronounceable;
- (NSString *)generateRandom;
- (NSString *)generatePattern:(NSString *)pattern;
- (NSString *)generatePassphrase;
- (NSString *)generatePassphraseWithSeparatorType:(PFSeparatorType)separatorType;
- (uint)randomNumber:(uint)limit;
- (NSString *)getPasswordCharacterType:(PFCharacterType)type;
- (BOOL)isCharacterType:(PFCharacterType)type character:(NSString *)character;
- (NSString *)getNameForPasswordType: (PFPasswordType)type;
- (NSDictionary *)getAllPasswordTypes;
-(PFPasswordType)getPasswordTypeByIndex:(NSInteger)index;
@end
