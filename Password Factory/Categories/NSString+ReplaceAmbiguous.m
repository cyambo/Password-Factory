//
//  NSString+ReplaceAmbiguous.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/12/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "NSString+ReplaceAmbiguous.h"
#import "NSString+MapCase.h"
static NSDictionary *map = nil;
@implementation NSString (ReplaceAmbiguous)
-(NSString *)replaceAmbiguous {
    if (map == nil) {
        map = @{
                @"I" : @[@"1"],
                @"O" : @[@"0"],
                @"l" : @[@"1"],
                @"o" : @[@"0"],
                @"O" : @[@"0"]
                };
    }

    return [self mapCase:100 map:map];
}
@end
