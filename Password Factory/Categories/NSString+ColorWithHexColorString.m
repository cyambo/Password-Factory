//
//  NSString+ColorWithHexColorString.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/13/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSString+ColorWithHexColorString.h"

@implementation NSString (ColorWithHexColorString)
/**
 Converts a hex color string into an NSColor
 From http://stackoverflow.com/questions/8697205/convert-hex-color-code-to-nscolor
 
 @return NSColor made from hex color string
 */
- (NSColor*)colorWithHexColorString {
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;


    NSScanner* scanner = [NSScanner scannerWithString:[self copy]];
    (void) [scanner scanHexInt:&colorCode]; // ignore error
    
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    
    result = [NSColor
              colorWithCalibratedRed:(CGFloat)redByte / 0xff
              green:(CGFloat)greenByte / 0xff
              blue:(CGFloat)blueByte / 0xff
              alpha:1.0];
    return result;
}
@end
