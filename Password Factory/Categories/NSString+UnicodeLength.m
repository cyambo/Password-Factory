//
//  NSString+UnicodeLength.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/16/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "NSString+UnicodeLength.h"

@implementation NSString (UnicodeLength)
-(NSUInteger)getUnicodeLength {
    __block NSUInteger i = 0;
    //using enumeration to get string length because that is as far as I know the only way to get the proper length with unicode strings
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        i++;
    }];
    return i;
}
@end
