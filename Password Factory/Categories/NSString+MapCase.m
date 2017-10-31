//
//  NSString+MapCase.m
//  Password Factory
//
//  Created by Cristiana Yambo on 10/30/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "NSString+MapCase.h"
static NSDictionary *map = nil;

@implementation NSString (MapCase)
-(NSString *)mapCase:(float)percent map:(NSDictionary *)toMap {
    map = toMap;
    if (percent > 1) {
        percent = 1;
    } else if(percent <= 0) {
        return self;
    }
    NSUInteger numReplace = floor(self.length * percent);
    if (numReplace > self.length) {
        numReplace = self.length;
    }
    NSMutableString *retval = [[NSMutableString alloc] init];
    NSMutableArray *toReplace = [[NSMutableArray alloc] init];
    for(int i =0; i < self.length; i++) {
        [toReplace addObject:@(i)];
    }
    toReplace = [[NSMutableArray alloc] initWithArray:[self shuffleArray:toReplace]];
    for(int i =0; i < self.length - numReplace; i++) {
        [toReplace removeLastObject];
    }
    toReplace = [[NSMutableArray alloc] initWithArray:[toReplace sortedArrayUsingSelector:@selector(compare:)]];
    for(int i=0; i < self.length; i++) {
        BOOL replaced = NO;
        if(toReplace.count) {
            NSUInteger item = [[toReplace objectAtIndex:0] integerValue];
            if (item == i) {
                replaced = YES;
                [retval appendString:[self getRandomSymbolForLetter:[self characterAtIndex:i]]];
                [toReplace removeObjectAtIndex:0];
            }
        }
        if (!replaced) {
            [retval appendString:[NSString stringWithFormat:@"%c",[self characterAtIndex:i]]];
        }
    }
    return retval;
}
- (NSString *)getRandomSymbolForLetter:(char)letter {
    NSString *charl = [NSString stringWithFormat:@"%c",letter ];
    if(map[charl]) {
        NSArray *choices = (NSArray *)map[charl];
        int at = arc4random() % choices.count;
        return [choices objectAtIndex:at];
    }
    return charl;
}
- (NSArray*)shuffleArray:(NSArray*)array {
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = (NSUInteger)arc4random_uniform((unsigned int)i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    return [NSArray arrayWithArray:temp];
}
@end
