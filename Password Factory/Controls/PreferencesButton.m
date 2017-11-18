//
//  PreferencesButton.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/16/15.
//  Copyright (c) 2015 c13. All rights reserved.
//

#import "PreferencesButton.h"
#import "StyleKit.h"
#import "Utilities.h"
@implementation PreferencesButton
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
        self.image = [StyleKit imageOfPreferencesButtonWithStrokeColor:[NSColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.75]];
        
    } else {
        self.image = [StyleKit imageOfPreferencesButtonWithStrokeColor:[NSColor colorWithRed: 0.31 green: 0.678 blue: 0.984 alpha: 1]];
    }
}
@end
