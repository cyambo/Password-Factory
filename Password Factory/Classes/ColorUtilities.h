//
//  ColorUtilities.h
//  Password Factory
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//
#import "constants.h"
#import <Foundation/Foundation.h>
#ifdef IS_MACOS
#define Color NSColor
#import <Cocoa/Cocoa.h>
#else
#define Color UIColor
#import <UIKit/UIKit.h>
#endif
@interface ColorUtilities : NSObject
+(Color *)getPasswordTextColor:(NSString *)subsring;
+(Color *)patternTypeToColor:(PFPatternTypeItem)type;
+(Color *)dodgeColor:(Color *)foregroundColor backgroundColor:(Color *)backgroundColor;
+(NSString *)colorToHexString:(Color *)color;
+(Color *)colorFromHexString:(NSString *)hex;
+(Color *)getDefaultsColor:(NSString *)defaultsKey;
+(void)setDefaultsColor:(NSString *)defaultsKey color:(Color *)color;
+(Color *)getStrengthColor:(float)strength;
#ifdef IS_MACOS
+(NSColorSpace *)colorSpace;
#endif
@end
