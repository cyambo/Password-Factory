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
#import "NSString+ColorWithHexColorString.h"
@implementation Utilities
/**
 Static method that returns the dark mode state
 
 @return yes if it is dark, no if it isnt
 */
+(BOOL)isDarkMode {
    if ([[DefaultsManager standardDefaults] boolForKey:@"isMenuApp"]) {
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
 Returns the colorspace we are using for the app

 @return NSColorSpace
 */
+(NSColorSpace *)colorSpace {
    return [NSColorSpace extendedSRGBColorSpace];
}
/**
 Generates a cryptographic random number
 
 @param limit upper limit of number
 @return random uint
 */
+(uint)randomInt:(uint)limit {
    if (limit == 0) {
        return 0;
    }
    int32_t randomNumber = 0;
    uint result = SecRandomCopyBytes(kSecRandomDefault, 4, (uint8_t*) &randomNumber);
    if(result == 0) {
        return randomNumber % limit;
    } else {
        NSLog(@"SecRandomCopyBytes failed for some reason");
    }
    return 1;
}
@end
