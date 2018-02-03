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
#import "PasswordStorage.h"
#import "PasswordFactoryConstants.h"
#import "NSString+ColorWithHexColorString.h"
#import "ColorUtilities.h"
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
    text = text == nil ? @"" : text;
    //not highlighted, so use the default color
    if (!highlighted) {
        NSColor *dColor = [[d stringForKey:@"defaultTextColor"] colorWithHexColorString];
        //dodge if dark mode
        if ([Utilities isDarkMode]) {
            dColor = [ColorUtilities dodgeColor:dColor backgroundColor:[Utilities getBackgroundColor]];
        }
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName: dColor,
                                     NSFontAttributeName: [NSFont systemFontOfSize:size]
                                     };
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
        
    } else {
        //colors the password text based upon color wells in preferences

        //uses AttributedString to color password
        __block NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:size]}];

        //colorizing password label
        [s beginEditing];
        //loops through the string and sees if it is in each type of string to determine the color of the character
        //using 'NSStringEnumerationByComposedCharacterSequences' so that emoji and other extended characters are enumerated as a single character
        [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable at, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            NSColor *c = [ColorUtilities getPasswordTextColor:at];
            if ([Utilities isDarkMode]) {
                c = [ColorUtilities dodgeColor:c backgroundColor:[Utilities getBackgroundColor]];
            }
            //set the character color
            [s addAttribute:NSForegroundColorAttributeName value:c range:substringRange];
        }];
        
        [s endEditing];
        //update the password field
        return s;
    }
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

+(void)setRemoteStore {
    DefaultsManager *d = [DefaultsManager get];
    BOOL iCloudIsAvailable = NSFileManager.defaultManager.ubiquityIdentityToken != nil;
    [d setBool:iCloudIsAvailable forKey:@"iCloudIsAvailable"];
    if (iCloudIsAvailable && [d boolForKey:@"enableRemoteStore"]) {
        [[NSApplication sharedApplication] registerForRemoteNotificationTypes:NSRemoteNotificationTypeNone];
        [d enableRemoteStore:YES];
        if ([d boolForKey:@"storePasswords"]) {
            [[PasswordStorage get] enableRemoteStorage:true];
        }
    } else {
        [d setBool:NO forKey:@"enableRemoteStore"];
        [[NSApplication sharedApplication] unregisterForRemoteNotifications];
        [d enableRemoteStore:NO];
        if([d boolForKey:@"storeInitialized"]) {
            [[PasswordStorage get] enableRemoteStorage:false];
        }
    }
}
@end
