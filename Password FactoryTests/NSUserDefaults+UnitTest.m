//
//  NSUserDefaults+UnitTest.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/14/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "NSUserDefaults+UnitTest.h"
#import <OCMock/OCMock.h>
#import <objc/runtime.h>

static SEL originalSelector;
static SEL mySelector;
static BOOL mocking;
static id mockUserDefaults;
@implementation NSUserDefaults (UnitTest)

//method swizzles standardUserDefaults with mockStandardUserDefaults
+(void)swapMethods {
    if (mocking) {
        SwizzleClassMethod([self class], mySelector, originalSelector);
        mockUserDefaults = nil; //when we swap out, kill the mock object so we can recreated it later with new args
        mocking = NO;
    } else {
        SwizzleClassMethod([self class], originalSelector, mySelector);
        mocking = YES;
    }
}
+(NSUserDefaults *)mockStandardUserDefaults {
    if (mockUserDefaults == nil) {
        mockUserDefaults = [OCMockObject niceMockForClass:[NSUserDefaults class]];
    }
    return mockUserDefaults;
}
+(void)load {
    originalSelector = @selector(standardUserDefaults);
    mySelector = @selector(mockStandardUserDefaults);
    mocking = NO;
}

void SwizzleClassMethod(Class c, SEL orig, SEL new) {
    
    Method origMethod = class_getClassMethod(c, orig);
    Method newMethod = class_getClassMethod(c, new);
    
    c = object_getClass((id)c);
    
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}
@end
