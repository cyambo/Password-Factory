//
//  StrengthControl.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/19/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "StrengthControl.h"
#import "ColorUtilities.h"
@implementation StrengthControl
-(instancetype)initWithFrame:(NSRect)frameRect {
    
    self = [super initWithFrame:frameRect];
    self.strength = 0.25;
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}
-(NSColor *)getStrengthColor {
    return [ColorUtilities getStrengthColor:self.strength];
}
-(void)updateStrength:(float)strength {
    //bounds fitting
    if (strength < 0.0) {strength = 0.0;}
    if (strength > 1.0) {strength = 1.0;}
    if (strength >=0.0 && strength <= 1.0) {
        self.strength = strength;
        [self setNeedsDisplay:YES];
    }
}
@end
