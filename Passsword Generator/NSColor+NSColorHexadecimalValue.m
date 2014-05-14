//
//  NSColor+NSColorHexadecimalValue.m
//  Passsword Generator
//  From : https://developer.apple.com/library/mac/qa/qa1576/_index.html
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "NSColor+NSColorHexadecimalValue.h"


@implementation NSColor (NSColorHexadecimalValue)
-(NSString *)hexadecimalValueOfAnNSColor
{
    int redIntValue, greenIntValue, blueIntValue;
    NSString *redHexValue, *greenHexValue, *blueHexValue;
    
    //Convert the NSColor to the RGB color space before we can access its components
    NSColor *convertedColor=[self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    if(convertedColor)
    {

        
        // Convert the components to numbers (unsigned decimal integer) between 0 and 255
        redIntValue=[convertedColor redComponent]* 255;
        greenIntValue=[convertedColor greenComponent]* 255;
        blueIntValue=[convertedColor blueComponent]* 255;
        
        // Convert the numbers to hex strings
        redHexValue=[NSString stringWithFormat:@"%02X", redIntValue];
        greenHexValue=[NSString stringWithFormat:@"%02X", greenIntValue];
        blueHexValue=[NSString stringWithFormat:@"%02X", blueIntValue];
        
        // Concatenate the red, green, and blue components' hex strings together
        return [NSString stringWithFormat:@"%@%@%@", redHexValue, greenHexValue, blueHexValue];
    }
    return nil;
}
@end

