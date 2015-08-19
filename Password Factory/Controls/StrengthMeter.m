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
    [StyleKit drawStrengthMeterWithStrengthColor:[self getStrengthColor] strength:self.strength];

}

@end
