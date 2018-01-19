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
-(void)updateStrength:(float)strength;
-(NSColor *)getStrengthColor;
+(NSColor *)getStrengthColorForStrength:(float)strength;
@end
