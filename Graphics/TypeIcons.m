//
//  TypeIcons.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "TypeIcons.h"
#import "StyleKit.h"

@implementation TypeIcons

/**
 Gets the type icon with the stroke of specified color

 @param color Stroke color to use
 @param type PFPasswordType
 @return type icon image
 */
+(NSImage *)getTypeIconWithColor:(NSColor *)color type:(PFPasswordType)type {
    switch(type) {
        case PFRandomType:
            return [StyleKit imageOfRandomTypeWithTypeColor:color];
            break;
        case PFStoredType:
            return [StyleKit imageOfStoredTypeWithTypeColor:color];
            break;
        case PFPatternType:
            return [StyleKit imageOfPatternTypeWithTypeColor:color];
            break;
        case PFPassphraseType:
            return [StyleKit imageOfPassphraseTypeWithTypeColor:color];
            break;
        case PFPronounceableType:
            return [StyleKit imageOfPronounceableTypeWithTypeColor:color];
            break;
        case PFAdvancedType:
            return [StyleKit imageOfAdvancedTypeWithTypeColor:color];
            break;
    }
}

/**
 Gets the type icon in the default color

 @param type PFPasswordType
 @return type icon
 */
+(NSImage *)getTypeIcon:(PFPasswordType)type {
    NSColor *c = [NSColor colorWithRed: 0.31 green: 0.678 blue: 0.984 alpha: 1];
    return [TypeIcons getTypeIconWithColor:c type:type];
}

/**
 Gets the type icon in the alternate color
 
 @param type PFPasswordType
 @return type icon
 */
+(NSImage *)getAlternateTypeIcon:(PFPasswordType)type {
    NSColor *c = [NSColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    return [TypeIcons getTypeIconWithColor:c type:type];
}
@end
