//
//  OnlyIntegerFormatter.m
//  Password Factory
//
//  Created by Cristiana Yambo on 9/5/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "OnlyIntegerFormatter.h"

@implementation OnlyIntegerFormatter

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    //setting min and max based upon the IBInspectable values
    if (self.minValue ) {
        self.minimum = @(self.minValue);
    }
    if (self.maxValue) {
        self.maximum = @(self.maxValue);
    }
    self.allowsFloats = NO;
    self.generatesDecimalNumbers = NO;
    return self;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString *__autoreleasing  _Nullable *)newString errorDescription:(NSString *__autoreleasing  _Nullable *)error {
    //remove non-integer characters
    NSString  *numString = [[partialString componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    NSInteger num = [numString integerValue];
    if (num < self.minValue) {
        num = self.minValue;
    } else if (num > self.maxValue) {
        num = self.maxValue;
    }
    if (num != [numString integerValue]) {
        numString = [NSString stringWithFormat:@"%ld",(long)num];
    }
    if ([numString isEqualToString:partialString]) {
        return YES;
    }
    *newString = numString;
    return NO;
}
@end
