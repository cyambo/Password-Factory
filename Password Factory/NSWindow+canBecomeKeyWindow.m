//
//  NSWindow+canBecomeKeyWindow.m
//  Password Factory
//
//  Created by Cristiana Yambo on 6/17/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "NSWindow+canBecomeKeyWindow.h"

@implementation NSWindow (canBecomeKeyWindow)
-(BOOL)canBecomeKeyWindow {
    if([self class]==NSClassFromString(@"NSStatusBarWindow")) {
        NSLog(@"SBW");
        return NO;
    }
    NSLog(@"Not SBW");
    return YES;
}
@end
