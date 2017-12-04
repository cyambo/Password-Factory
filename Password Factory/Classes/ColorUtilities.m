//
//  ColorUtilities.m
//  Password Factory
//
//  Created by Cristiana Yambo on 12/3/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "ColorUtilities.h"
#import "DefaultsManager.h"
#import "PasswordFactory.h"
#import "PasswordFactoryConstants.h"
@implementation ColorUtilities
+(Color *)getPasswordTextColor:(NSString *)subsring {
    DefaultsManager *d = [DefaultsManager get];
    PasswordFactory *f = [PasswordFactory get];
    NSString *color = [d stringForKey:@"defaultTextColor"];
    
    if (subsring.length == 1) { //only color strings with length of one, anything greater is an emoji or other long unicode charcacters
        if ([f isCharacterType:PFUpperCaseLetters character:subsring]) { //are we an uppercase character
            color = [d stringForKey:@"upperTextColor"];
        } else if ([f isCharacterType:PFLowerCaseLetters character:subsring]){ //lowercase character?
            color = [d stringForKey:@"lowerTextColor"];
        } else if ([f isCharacterType:PFNumbers character:subsring]){ //number?
            color = [d stringForKey:@"numberTextColor"];
        } else if ([f isCharacterType:PFSymbols character:subsring]){ //symbol?
            color = [d stringForKey:@"symbolTextColor"];
        }
    }
    return [ColorUtilities colorFromHexString:color];
}
+(Color *)colorFromHexString:(NSString *)hex {
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    
    NSScanner* scanner = [NSScanner scannerWithString:[hex copy]];
    (void) [scanner scanHexInt:&colorCode]; // ignore error
    
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    return  [Color colorWithRed:(CGFloat)redByte / 0xff
                           green:(CGFloat)greenByte / 0xff
                            blue:(CGFloat)blueByte / 0xff
                           alpha:1.0];
}
+(NSString *)colorToHexString:(Color *)color {
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;
    
    //Convert the NSColor to the RGB color space before we can access its components
    Color *c;
#ifdef IOS
    c = color;
#else
    c = [color colorUsingColorSpace:[ColorUtilities colorSpace]];
#endif
    
    if(c) {
        CGFloat r,g,b;
#ifdef IOS
        [c getRed:&r green:&g blue:&b alpha:nil];
#else
        Color *tmp = [color colorUsingColorSpace:[ColorUtilities colorSpace]];
        r = tmp.redComponent;
        g = tmp.greenComponent;
        b = tmp.blueComponent;
#endif
        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue = r * 255;
        greenIntValue = g * 255;
        blueIntValue = b * 255;
        
        // Convert the numbers to hex strings
        redHexValue=[NSString stringWithFormat:@"%02X", redIntValue];
        greenHexValue=[NSString stringWithFormat:@"%02X", greenIntValue];
        blueHexValue=[NSString stringWithFormat:@"%02X", blueIntValue];
        
        // Concatenate the red, green, and blue components' hex strings together
        return [NSString stringWithFormat:@"%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    return @"000000";
}
+(Color *)patternTypeToColor:(PFPatternTypeItem)type {
    PasswordFactoryConstants *c = [PasswordFactoryConstants get];
    Color *baseColor = [Color colorWithRed:0.74 green:0.21 blue:0.23 alpha:1.0];
    NSUInteger hueSteps = c.patternTypeIndex.count + 1;
    NSUInteger at = (NSUInteger)type - (NSUInteger)PFNumberType;
    float hue = (float)at / (float)hueSteps;
    //changing hue from 0 - 1 to get all different colors
    CGFloat saturation;
    CGFloat brightness;
#ifdef IOS
    [baseColor getHue:nil saturation:&saturation brightness:&brightness alpha:nil];
#else
    saturation = baseColor.saturationComponent;
    brightness = baseColor.brightnessComponent;
#endif
    Color *color = [Color colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
    return color;
}
+(Color *)dodgeColor:(Color *)foregroundColor backgroundColor:(Color *)backgroundColor {
    CGFloat r,g,b,fr,fg,fb,br,bg,bb;
#ifdef IOS
    [foregroundColor getRed:&fr green:&fg blue:&fb alpha:nil];
    [backgroundColor getRed:&br green:&bg blue:&bb alpha:nil];
#else
    Color *fgc = [foregroundColor colorUsingColorSpace:[ColorUtilities colorSpace]];
    Color *bgc = [backgroundColor colorUsingColorSpace:[ColorUtilities colorSpace]];
    fr = fgc.redComponent;
    fg = fgc.greenComponent;
    fb = fgc.blueComponent;
    br = bgc.redComponent;
    bg = bgc.greenComponent;
    bb = bgc.blueComponent;
#endif
    r = [ColorUtilities dodge:fr background:br];
    g = [ColorUtilities dodge:fg background:bg];
    b = [ColorUtilities dodge:fb background:bb];
    return [Color colorWithRed:r green:g blue:b alpha:1.0];
}
+(CGFloat)dodge:(CGFloat)foreground background:(CGFloat)background{
    CGFloat A = foreground * 255;
    CGFloat B = background * 255;
    
    B+= (B*0.5);
    
    CGFloat r = (A + B) / 255;
    if (r >= 1) {
        return 1;
    } else {
        return r;
    }
}
#ifndef IOS
+(NSColorSpace *)colorSpace {
    return [NSColorSpace sRGBColorSpace];
}
#endif
@end
