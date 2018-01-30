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
@property (nonatomic, strong) NSString *escapedSymbols;
@property (nonatomic, strong) NSString *upperCase;
@property (nonatomic, strong) NSString *lowerCase;
@property (nonatomic, strong) NSString *numbers;
@property (nonatomic, strong) NSString *nonAmbiguousUpperCase;
@property (nonatomic, strong) NSString *nonAmbiguousLowerCase;
@property (nonatomic, strong) NSString *nonAmbiguousNumbers;
@property (nonatomic, strong) NSArray *phoneticSounds;
@property (nonatomic, strong) NSArray *phoneticSoundsTwo;
@property (nonatomic, strong) NSArray *phoneticSoundsThree;
@property (nonatomic, strong) NSDictionary *passwordCharacterTypes;
@property (nonatomic, strong) NSDictionary *passwordTypes;
@property (nonatomic, strong) NSDictionary *passwordNameToType;
@property (nonatomic, strong) NSDictionary *caseTypes;
@property (nonatomic, strong) NSDictionary *separatorTypes;
@property (nonatomic, strong) NSDictionary *separatorTypeValues;
@property (nonatomic, strong) NSDictionary *patternCharacterToType;
@property (nonatomic, strong) NSDictionary *patternTypeToName;
@property (nonatomic, strong) NSDictionary *patternTypeToCharacter;
@property (nonatomic, strong) NSDictionary *patternTypeToDescription;
@property (nonatomic, strong) NSArray *passwordTypesIndex;
@property (nonatomic, strong) NSArray *caseTypeIndex;
@property (nonatomic, strong) NSArray *separatorTypeIndex;
@property (nonatomic, strong) NSArray *patternTypeIndex;
@property (nonatomic, strong) NSArray *disabledSyncKeys;
-(PFPasswordType)getPasswordTypeByIndex:(NSUInteger)index;
-(PFCaseType)getCaseTypeByIndex:(NSUInteger)index;
-(PFSeparatorType)getSeparatorTypeByIndex:(NSUInteger)index;
-(PFPatternTypeItem)getPatternTypeByIndex:(NSUInteger)index;
-(NSString *)getNameForPasswordType:(PFPasswordType)type;
-(NSString *)getNameForCaseType:(PFCaseType)type;
-(NSString *)getNameForPatternTypeItem:(PFPatternTypeItem)type;
-(NSString *)getNameForSeparatorType:(PFSeparatorType)type;

+ (instancetype)get;
@end
