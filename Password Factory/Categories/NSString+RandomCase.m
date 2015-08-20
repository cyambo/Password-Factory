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
    NSMutableString *r = [[NSMutableString alloc] init];
    for (int i = 0; i < self.length; i++) {
        int yn = arc4random() % 2;
        char c = [self characterAtIndex:i];
        if (yn) {
            c = tolower(c);
        } else {
            c = toupper(c);
        }
        [r appendFormat:@"%c",c];
    }

    return r;
}
@end
