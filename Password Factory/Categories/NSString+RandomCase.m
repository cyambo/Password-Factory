//
//  NSString+RandomCase.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/20/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "NSString+RandomCase.h"

@implementation NSString (RandomCase)
- (NSString *)randomCase {
    __block NSMutableString *r = [[NSMutableString alloc] init];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        int yn = arc4random() % 2;
        if (yn) {
            character = [character lowercaseString];
        } else {
            character = [character uppercaseString];
        }
        [r appendString:character];
    }];
    return r;
}
@end
