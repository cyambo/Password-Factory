//
//  BorderedButton.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/8/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "BorderedButton.h"

@implementation BorderedButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if (self.isHighlighted) {
        NSColor *bg = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.1];
        self.layer.backgroundColor = [bg CGColor];
        self.layer.opacity = 0.4;
    } else {
        self.layer.backgroundColor = [[NSColor clearColor] CGColor];
        self.layer.opacity = 1.0;
    }
}
@end
