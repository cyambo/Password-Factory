//
//  TextField.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "TextField.h"

@implementation TextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if (enabled) {
        self.textColor = [self.textColor colorWithAlphaComponent:1];
    } else {
        self.textColor = [self.textColor colorWithAlphaComponent:0.25];
    }
}
@end
