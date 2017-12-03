//
//  Utilities.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
@interface Utilities : NSObject
+(BOOL)isDarkMode;
+(NSAttributedString *)colorText:(NSString *)text size:(NSUInteger)size;
+(NSColorSpace *)colorSpace;

+(NSColor *)dodgeColor:(NSColor *)foregroundColor backgroundColor:(NSColor *)backgroundColor;
+(NSColor *)getBackgroundColor;
+(NSColor *)patternTypeToColor:(PFPatternTypeItem)type;
@end
