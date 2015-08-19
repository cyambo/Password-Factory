//
//  StrengthBox.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/19/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "StrengthBox.h"
#import "StyleKit.h"
@implementation StrengthBox

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [StyleKit drawStrengthBoxWithStrengthColor:[self getStrengthColor]];

    
}


@end
