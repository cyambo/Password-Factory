//
//  PasswordController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/4/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
#import "PasswordFactory.h"
#import "PasswordTypesViewController.h"

@class PasswordController;
@protocol PasswordControllerDelegate <NSObject>
-(void)passwordChanged:(NSString *)password;
@end
@interface PasswordController : NSObject <PasswordTypesViewControllerDelegate>
@property (nonatomic, assign) BOOL generateCrackTimeString;
@property (nonatomic, weak) id <PasswordControllerDelegate> delegate;
@property (nonatomic, assign) BOOL useStoredType;
@property (nonatomic, assign) BOOL useAdvancedType;
@property (nonatomic, strong) NSString *password;
+ (instancetype)get:(BOOL)useShared;
- (void)generatePassword:(PFPasswordType)type;
- (NSString *)generatePassword:(PFPasswordType)type withSettings:(NSDictionary *)settings;
- (void)setPasswordValue:(NSString *)passwordValue;
- (NSString *)getPasswordValue;
- (void)updatePasswordStrength;
- (float)getPasswordStrength;
- (NSString *)getCrackTimeString;
- (BOOL)isCharacterType:(PFCharacterType)type character:(NSString *)character;
- (NSString *)getNameForPasswordType: (PFPasswordType)type;
- (NSDictionary *)getAllPasswordTypes;
- (NSDictionary *)getFilteredPasswordTypes;
- (PFPasswordType)getPasswordTypeByIndex:(NSUInteger)index;
- (NSUInteger)getIndexByPasswordType:(PFPasswordType)type;
- (PasswordTypesViewController *)getViewControllerForPasswordType:(PFPasswordType)type;
- (NSDictionary *)getPasswordSettingsByType:(PFPasswordType)type;
@end
