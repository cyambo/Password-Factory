//
//  ColorUtilities.h
//  Password Factory
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//
#import "constants.h"
#import <Foundation/Foundation.h>
#if TARGET_OS_OSX
#define Color NSColor
#import <Cocoa/Cocoa.h>
#else
#define IOS 1
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
#ifndef IOS
+(NSColorSpace *)colorSpace;
#endif
@end
