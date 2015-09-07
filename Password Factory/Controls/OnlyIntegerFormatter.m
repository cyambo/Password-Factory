//
//  OnlyIntegerFormatter.m
//  Password Factory
//
//  Created by Cristiana Yambo on 9/5/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "OnlyIntegerFormatter.h"

@implementation OnlyIntegerFormatter
- (BOOL)isPartialStringValid:(NSString*)partialString newEditingString:(NSString**)newString errorDescription:(NSString**)error {
    if([partialString length] == 0) {
        return YES;
    }
    
    NSScanner* scanner = [NSScanner scannerWithString:partialString];
    
    if(!([scanner scanInt:0] && [scanner isAtEnd])) {
        return NO;
    }
    
    return YES;
}
@end
