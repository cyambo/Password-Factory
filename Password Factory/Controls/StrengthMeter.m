//
//  StrengthMeter.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/13/15.
//  Copyright (c) 2015 c13. All rights reserved.
//

#import "StrengthMeter.h"
#import "StyleKit.h"
@implementation StrengthMeter

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    float strength = self.strength + 0.01; // give a little size to zero strength
    [StyleKit drawStrengthMeterWithStrengthColor:[self getStrengthColor] strength:strength size:dirtyRect.size];
}

@end
