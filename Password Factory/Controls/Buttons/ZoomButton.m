//
//  ZoomButton.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "ZoomButton.h"
#import "StyleKit.h"
#import "Utilities.h"
@implementation ZoomButton

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.bordered = NO;
    self.imagePosition = NSImageOnly;
    [self setButtonType:NSMomentaryChangeButton];
    self.bezelStyle = NSRegularSquareBezelStyle;


    return self;
    
}
-(void)viewWillDraw {
    if ([Utilities isDarkMode]) {
        self.image = [StyleKit imageOfZoomWithZoomStroke:[NSColor whiteColor]];
        
    } else {
        self.image = [StyleKit imageOfZoomWithZoomStroke:[NSColor blackColor]];
    }
    [self setAlphaValue:0.5];
}
@end
