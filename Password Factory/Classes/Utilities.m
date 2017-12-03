//
//  Utilities.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Utilities.h"
#import "DefaultsManager.h"
#import "PasswordFactory.h"
#import "PasswordFactoryConstants.h"
#import "NSString+ColorWithHexColorString.h"
@implementation Utilities
/**
 Static method that returns the dark mode state
 
 @return yes if it is dark, no if it isnt
 */
+(BOOL)isDarkMode {
    if ([[DefaultsManager get] boolForKey:@"isMenuApp"]) {
        NSString *osxMode = [[DefaultsManager standardDefaults] stringForKey:@"AppleInterfaceStyle"];
        return [osxMode isEqualToString:@"Dark"];
    } else {
        return NO;
    }
}
+(NSAttributedString *)colorText:(NSString *)text size:(NSUInteger)size {
    DefaultsManager *d = [DefaultsManager get];
    //default text color from prefs
    BOOL highlighted = [d boolForKey:@"colorPasswordText"];
    NSColor *dColor = [[d stringForKey:@"defaultTextColor"] colorWithHexColorString];
    if (!highlighted) {
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName: dColor,
                                     NSFontAttributeName: [NSFont systemFontOfSize:size]
                                     };
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
        
    } else {
        //colors the password text based upon color wells in preferences
        
        NSColor *nColor = [[d stringForKey:@"numberTextColor"] colorWithHexColorString];
        NSColor *cColor = [[d stringForKey:@"upperTextColor"] colorWithHexColorString];
        NSColor *clColor = [[d stringForKey:@"lowerTextColor"] colorWithHexColorString];
        NSColor *sColor = [[d stringForKey:@"symbolTextColor"] colorWithHexColorString];
        //if we are using dark mode, then dodge all the colors to make them brighter
        if ([Utilities isDarkMode]) {
            NSColor *bg = [Utilities getBackgroundColor];
            nColor = [Utilities dodgeColor:nColor backgroundColor:bg];
            cColor = [Utilities dodgeColor:cColor backgroundColor:bg];
            clColor = [Utilities dodgeColor:clColor backgroundColor:bg];
            sColor = [Utilities dodgeColor:sColor backgroundColor:bg];
        }
        //uses AttributedString to color password
        
        __block NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:size]}];
        PasswordFactory *f = [PasswordFactory get];
        //colorizing password label
        [s beginEditing];
        //loops through the string and sees if it is in each type of string to determine the color of the character
        //using 'NSStringEnumerationByComposedCharacterSequences' so that emoji and other extended characters are enumerated as a single character
        [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable at, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            NSColor *c = dColor; //set a default color of the text to the default color
            if(substringRange.length == 1) { //only color strings with length of one, anything greater is an emoji or other long unicode charcacters
                if ([f isCharacterType:PFUpperCaseLetters character:at]) { //are we an uppercase character
                    c = cColor;
                } else if ([f isCharacterType:PFLowerCaseLetters character:at]){ //lowercase character?
                    c = clColor;
                } else if ([f isCharacterType:PFNumbers character:at]){ //number?
                    c = nColor;
                } else if ([f isCharacterType:PFSymbols character:at]){ //symbol?
                    c = sColor;
                } else {
                    c = dColor;
                }
                //set the character color
                [s addAttribute:NSForegroundColorAttributeName value:c range:substringRange];
            }
        }];
        
        [s endEditing];
        //update the password field
        return s;
    }
}

/**
 Gets the color of a PFPatternTypeItem for highlighting

 @param type PFPatternTypeItem
 @return color of item
 */
+(NSColor *)patternTypeToColor:(PFPatternTypeItem)type {
    PasswordFactoryConstants *c = [PasswordFactoryConstants get];
    NSColor *baseColor = [NSColor colorWithCalibratedRed:0.74 green:0.21 blue:0.23 alpha:1.0];
    NSUInteger hueSteps = c.patternTypeIndex.count + 1;
    NSUInteger at = (NSUInteger)type - (NSUInteger)PFNumberType;
    float hue = (float)at / (float)hueSteps;
    //changing hue from 0 - 1 to get all different colors
    NSColor *color = [NSColor colorWithHue:hue saturation:baseColor.saturationComponent brightness:baseColor.brightnessComponent alpha:1.0];
    if ([Utilities isDarkMode]) {
        return [Utilities dodgeColor:color backgroundColor:[Utilities getBackgroundColor]];
    } else {
        return color;
    }
    
}
/**
 Dodge on a color component
 
 @param foreground Foreground Color Component(from 0 - 1)
 @param background Background Color Component(from 0 - 1)
 @return Dodged component
 */
+(float)dodge:(float)foreground background:(float)background{
    float A = foreground * 255;
    float B = background * 255;
    
    B+= (B*0.5);
    
    float r = (A + B) / 255;
    if (r >= 1) {
        return 1;
    } else {
        return r;
    }
}

/**
 Runs a linear dodge on a color
 
 @param foregroundColor color to dodge
 @param backgroundColor Background of color
 @return Dodged color
 */
+(NSColor *)dodgeColor:(NSColor *)foregroundColor backgroundColor:(NSColor *)backgroundColor {
    NSColor *fg = [foregroundColor colorUsingColorSpace:[Utilities colorSpace]];
    NSColor *bg = [backgroundColor colorUsingColorSpace:[Utilities colorSpace]];
    float r = [Utilities dodge:fg.redComponent background:bg.redComponent];
    float g = [Utilities dodge:fg.greenComponent background:bg.greenComponent];
    float b = [Utilities dodge:fg.blueComponent  background:bg.blueComponent];
    return [[NSColor colorWithCalibratedRed:r green:g blue:b alpha:1]  colorUsingColorSpace:[Utilities colorSpace]];
}
/**
 Returns the colorspace we are using for the app

 @return NSColorSpace
 */
+(NSColorSpace *)colorSpace {
    return [NSColorSpace sRGBColorSpace];
}


/**
 Gets the background color depending on dark mode status

 @return background NSColor
 */
+(NSColor *)getBackgroundColor {
    if([Utilities isDarkMode]) {
        return [NSColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1.0];
    } else {
        return [NSColor whiteColor];
    }
}
@end
