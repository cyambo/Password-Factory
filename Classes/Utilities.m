//
//  Utilities.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "Utilities.h"
#import "DefaultsManager.h"
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
@end
