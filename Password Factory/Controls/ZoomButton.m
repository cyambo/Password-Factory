//
//  ZoomButton.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "ZoomButton.h"
#import "StyleKit.h"
@implementation ZoomButton

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.bordered = NO;
    self.imagePosition = NSImageOnly;
    [self setButtonType:NSMomentaryChangeButton];
    self.bezelStyle = NSRegularSquareBezelStyle;
    self.image = [StyleKit imageOfZoom];
    [self setAlphaValue:0.25];
    return self;
    
}

@end
