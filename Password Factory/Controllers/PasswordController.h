//
//  PasswordController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "constants.h"

#ifdef IS_MACOS
#import "PasswordTypesViewController.h"
#endif

#import "PasswordFactory.h"


@class PasswordController;
@protocol PasswordControllerDelegate <NSObject>
-(void)passwordChanged:(NSString *)password;
@end
#ifdef IS_MACOS
@interface PasswordController : NSObject <PasswordTypesViewControllerDelegate>
#else
@interface PasswordController : NSObject
#endif
@property (nonatomic, assign) BOOL generateCrackTimeString;
@property (nonatomic, weak) id <PasswordControllerDelegate> delegate;
@property (nonatomic, assign) BOOL useStoredType;
@property (nonatomic, assign) BOOL useAdvancedType;
@property (nonatomic, strong) NSString *password;
+ (instancetype)get;
#ifdef IS_MACOS
- (void)generatePassword:(PFPasswordType)type;
#else
- (NSString *)generatePassword:(PFPasswordType)type;
#endif
- (NSString *)generatePassword:(PFPasswordType)type withSettings:(NSDictionary *)settings;
- (void)setPasswordValue:(NSString *)passwordValue;
- (NSString *)getPasswordValue;
- (void)updatePasswordStrength;
- (float)getPasswordStrength;
- (NSString *)getCrackTimeString;
-(NSString *)getCrackTimeString:(NSString *)password;
- (BOOL)isCharacterType:(PFCharacterType)type character:(NSString *)character;
- (NSString *)getNameForPasswordType: (PFPasswordType)type;
- (NSDictionary *)getAllPasswordTypes;
- (NSDictionary *)getFilteredPasswordTypes;
- (PFPasswordType)getPasswordTypeByIndex:(NSUInteger)index;
- (NSUInteger)getIndexByPasswordType:(PFPasswordType)type;
#ifdef IS_MACOS
- (PasswordTypesViewController *)getViewControllerForPasswordType:(PFPasswordType)type;
#endif
- (NSDictionary *)getPasswordSettingsByType:(PFPasswordType)type;
@end
