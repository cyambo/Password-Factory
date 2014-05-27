//
//  TextField.m
//  Passsword Factory
//
//  Created by Cristiana Yambo on 5/27/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "TextField.h"

@implementation TextField

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (BOOL)becomeFirstResponder {
    BOOL okToChange = [super becomeFirstResponder];
    if (okToChange) [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
    return okToChange;
}

- (BOOL)resignFirstResponder {
    BOOL okToChange = [super resignFirstResponder];
    if (okToChange) [self setKeyboardFocusRingNeedsDisplayInRect: [self bounds]];
    return okToChange;
}
-(void)copy:(id)sender {
    NSLog(@"COPCDSCSDCSD");
}

-(void)cut:(id)sender {
    NSLog(@"CUT");
}
@end
