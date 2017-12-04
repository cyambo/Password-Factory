//
//  NSString+ColorWithHexColorString.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/13/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSString+ColorWithHexColorString.h"
#import "ColorUtilities.h"
@implementation NSString (ColorWithHexColorString)

- (NSColor*)colorWithHexColorString {
    return [ColorUtilities colorFromHexString:self];
}
@end
