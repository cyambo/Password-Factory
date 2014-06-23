//
//  NSWindow+canBecomeKeyWindow.m
//  Password Factory
//
//  Created by Cristiana Yambo on 6/17/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "NSWindow+canBecomeKeyWindow.h"
#import "AppDelegate.h"
@implementation NSWindow (canBecomeKeyWindow)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

-(BOOL)canBecomeKeyWindow {


    if ([self class]==NSClassFromString(@"NSStatusBarWindow")) {
        AppDelegate *d = (AppDelegate *)[NSApp delegate];
        if ([d.statusView isVisible]) {
           return NO; 
        }
        
    }

    return YES;

}
#pragma clang diagnostic pop
@end
