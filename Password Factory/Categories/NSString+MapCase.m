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

/**
 Replaces individual characters with randomized variants

 @param percent Percent of the characters to map
 @param toMap mapping to use
 @return mapped string
 */
-(NSString *)mapCase:(NSUInteger)percent map:(NSDictionary *)toMap {
    map = toMap;
    if (percent > 100) {
        percent = 100;
    }
    //setting the number of characters we need to replace based upon the percent
    NSUInteger numReplace = floor(self.length * percent / 100);
    if (numReplace > self.length) {
        numReplace = self.length;
    }
    
    //toReplace is an array of numbers that contain the indexes that need to be replaced
    NSMutableArray *toReplace = [[NSMutableArray alloc] init];
    //first create an array containing every index
    for(int i = 0; i < self.length; i++) {
        [toReplace addObject:@(i)];
    }
    //randomize the array
    toReplace = [[NSMutableArray alloc] initWithArray:[self shuffleArray:toReplace]];
    //remove a number based upon the percent we need replaced
    if (numReplace < self.length) {
        [toReplace removeObjectsInRange:NSMakeRange(0, self.length - numReplace)];
    }
    //if we don't need to replace anything, just return the same string
    if(toReplace.count == 0) {
        return self;
    }
    //sort it so we can find in the loop
    toReplace = [[NSMutableArray alloc] initWithArray:[toReplace sortedArrayUsingSelector:@selector(compare:)]];
    __block int i = 0;
    __block NSMutableString *retval = [[NSMutableString alloc] init];
    //now go through the string
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        
        BOOL replaced = NO;
        if(toReplace.count) {
            NSUInteger item = [toReplace[0] integerValue];
            if (item == i) {
                replaced = YES;
                [retval appendString:[self getRandomSymbolForLetter:character]];
                [toReplace removeObjectAtIndex:0];
            }
        }
        if (!replaced) {
            [retval appendString:character];
        }
        i++;
    
    }];

    return retval;
}
- (NSString *)getRandomSymbolForLetter:(NSString*)letter {
    if(map[letter] != nil) {
        NSArray *choices = (NSArray *)map[letter];
        if (choices == nil) {
            NSLog(@"BREAKPONT LOG - NIL CHOICES");
        }
        int at = arc4random() % choices.count;
        NSString *choice = [choices objectAtIndex:at];
        if (choice != nil) {
            return choice;
        } else {
            NSLog(@"BREAKPOINT LOG - NIL CHOICE");
        }
    }
    return letter;
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
