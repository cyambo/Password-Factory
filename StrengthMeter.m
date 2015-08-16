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


-(instancetype)initWithFrame:(NSRect)frameRect {

    self = [super initWithFrame:frameRect];
    self.strength = 0.25;
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [StyleKit drawStrengthMeterWithStrengthColor:[self getStrengthColor] strength:self.strength];



}
-(NSColor *)getStrengthColor {
    float hue = self.strength *.3;
    NSColor *_strengthColors = [NSColor colorWithCalibratedRed: 0.848 green: 0.077 blue: 0.077 alpha: 1];
    return [NSColor colorWithCalibratedHue: hue saturation: _strengthColors.saturationComponent brightness: _strengthColors.brightnessComponent alpha: _strengthColors.alphaComponent];
}
-(void)updateStrength:(float)strength {

    if (strength >=0.0 && strength <= 100.0) {
        self.strength = strength/100;
        self.floatValue = strength;
        [self setNeedsDisplay:YES];
    }
}
@end
