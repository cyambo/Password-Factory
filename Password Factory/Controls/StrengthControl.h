//
//  StrengthControl.h
//  Password Factory
//
//  Created by Cristiana Yambo on 8/19/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StrengthControl : NSView
@property (nonatomic, assign) float strength;
@property (nonatomic, assign) float floatValue;
-(void)updateStrength:(float)strength;
-(NSColor *)getStrengthColor;
@end
