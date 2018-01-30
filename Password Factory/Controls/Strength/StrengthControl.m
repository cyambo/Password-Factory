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
    return [StrengthControl getStrengthColorForStrength:self.strength];
}
+(NSColor *)getStrengthColorForStrength:(float)strength {
    //creating a color from red to purple, with purple being the strongest
    NSColor *baseColor = [NSColor colorWithCalibratedRed: 0.9 green: 0.077 blue: 0.077 alpha: 1];
    float hue = strength *.7;
    float saturation = baseColor.saturationComponent - (hue * 0.4);
    return [NSColor colorWithCalibratedHue: hue saturation: saturation brightness: baseColor.brightnessComponent alpha: baseColor.alphaComponent];
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
