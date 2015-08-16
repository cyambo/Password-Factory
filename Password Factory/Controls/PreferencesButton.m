//
//  PreferencesButton.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/16/15.
//  Copyright (c) 2015 c13. All rights reserved.
//

#import "PreferencesButton.h"
#import "StyleKit.h"
@implementation PreferencesButton
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.bordered = NO;
    self.imagePosition = NSImageOnly;
    [self setButtonType:NSMomentaryChangeButton];
    self.bezelStyle = NSRegularSquareBezelStyle;
    self.image = [StyleKit imageOfPreferencesButton];
    return self;
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
