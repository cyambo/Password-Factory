//
//  PasswordFactoryConstants.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface PasswordFactoryConstants : NSObject
@property (nonatomic, strong) NSString *symbols;
@property (nonatomic, strong) NSString *upperCase;
@property (nonatomic, strong) NSString *lowerCase;
@property (nonatomic, strong) NSString *numbers;
@property (nonatomic, strong) NSString *nonAmbiguousUpperCase;
@property (nonatomic, strong) NSString *nonAmbiguousLowerCase;
@property (nonatomic, strong) NSString *nonAmbiguousNumbers;
@property (nonatomic, strong) NSDictionary *characterPattern;
@property (nonatomic, strong) NSArray *phoneticSounds;
@property (nonatomic, strong) NSArray *phoneticSoundsTwo;
@property (nonatomic, strong) NSArray *phoneticSoundsThree;
@property (nonatomic, strong) NSDictionary *passwordCharacterTypes;
@property (nonatomic, strong) NSDictionary *passwordTypes;
+ (instancetype)get;
@end
