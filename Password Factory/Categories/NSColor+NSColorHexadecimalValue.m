//
//  NSColor+NSColorHexadecimalValue.m
//  Password Factory
//  From : https://developer.apple.com/library/mac/qa/qa1576/_index.html
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2017 Cristiana Yambo. All rights reserved.
//

#import "NSColor+NSColorHexadecimalValue.h"
#import "ColorUtilities.h"

@implementation NSColor (NSColorHexadecimalValue)
-(NSString *)hexadecimalValueOfAnNSColor {
    return [ColorUtilities colorToHexString:self];
}
@end

