//
//  ModeTextField.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "ModeTextField.h"
#import "Utilities.h"
@implementation ModeTextField

-(void)viewWillDraw {
    if ([Utilities isDarkMode]) {
        self.textColor = [NSColor whiteColor];
    } else {
        self.textColor = [NSColor blackColor];
    }
    [self setAlphaValue:0.5];
}

@end
