//
//  StrengthMeter.h
//  Password Factory
//
//  Created by Cristiana Yambo on 8/13/15.
//  Copyright (c) 2015 c13. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StrengthMeter : NSView
@property (nonatomic, assign) float strength;
@property (nonatomic, assign) float floatValue;
-(void)updateStrength:(float)strength;
@end
