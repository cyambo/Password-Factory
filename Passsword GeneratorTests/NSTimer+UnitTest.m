//
//  NSTimer+UnitTest.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/14/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "NSTimer+UnitTest.h"

#import <OCMock/OCMock.h>

static id mockTimer = nil;

@implementation NSTimer (UnitTest)
+(id)getTimer {
    if (mockTimer == nil) {
        mockTimer = [OCMockObject mockForClass:[NSTimer class]];
    }
    return mockTimer;
}
+(void)resetTimer {
    mockTimer = nil;
}
+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    return [[self class] getTimer];

}

@end
