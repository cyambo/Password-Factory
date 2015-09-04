//
//  NSString+SymbolCase.m
//  Password Factory
//
//  Created by Cristiana Yambo on 9/2/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "NSString+SymbolCase.h"
static NSDictionary *map = nil;
                             
                             
@implementation NSString (SymbolCase)
-(NSString *)symbolCase:(float)percent {

    map = @{
    @"A" : @[ @"4",  @"/-\\",  @"@",  @"^",  @"/\\"],
    @"B" : @[ @"8",  @"]3",  @"]8",  @"|3",  @"|8",  @"13"],
    @"C" : @[ @"(",  @"{",  @"[[",  @"<"],
    @"D" : @[ @")",  @"[}",  @")",  @"}"],
    @"E" : @[ @"3"],
    @"F" : @[ @"|=", @"(=", @"]="],
    @"G" : @[ @"6",  @"9",  @"(_>",  @"[[6",  @"&",  @"("],
    @"H" : @[ @"#",  @"|-|",  @"(-)",  @")-(",  @"}{",  @"}-{",  @"|~|"],
    @"I" : @[ @"1",  @"!",  @"|"],
    @"J" : @[ @"_|"],
    @"K" : @[ @"|<",  @"|{",  @"]<",  @"]<"],
    @"L" : @[ @"|", @"1", @"|_"],
    @"M" : @[ @"/\\/\\",  @"|\\/|",  @"/V\\",  @"^^"],
    @"N" : @[ @"/\\/",  @"|\\|",  @"~"],
    @"O" : @[ @"0",  @"()",  @"[]",  @"<>",  @"*"],
    @"P" : @[ @"|D",  @"|*",  @"|>"],
    @"Q" : @[ @"()",  @"0"],
    @"R" : @[ @"2"],
    @"S" : @[ @"5", @"$"],
    @"T" : @[ @"7",  @"+"],
    @"U" : @[ @"|_|",  @"\\_\\",  @"/_/"],
    @"V" : @[ @"\\/" ],
    @"W" : @[ @"\\/\\/",  @"|/\\|",  @"[/\\]",  @"(/\\)",  @"VV"],
    @"X" : @[ @"><",  @"}{",  @")("],
    @"Y" : @[ @"'/",  @"%",  @"`/"],
    @"Z" : @[ @"2",  @"7_"]
};
    
    if (percent > 1) {
        percent = 1;
    } else if(percent <= 0) {
        return self;
    }
    int numReplace = floor(self.length * percent);
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
            int item = [[toReplace objectAtIndex:0] integerValue];
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
    NSString *upper = [charl uppercaseString];
    if(map[upper]) {
        NSArray *choices = (NSArray *)map[upper];
        int at = arc4random() % choices.count;
        return [choices objectAtIndex:at];
    }
    return charl;
}
- (NSArray*)shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:temp];
}

@end
