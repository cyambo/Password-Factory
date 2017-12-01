//
//  VerticallyCenteredTextFieldCell.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/27/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "VerticallyCenteredTextFieldCell.h"

@implementation VerticallyCenteredTextFieldCell
-(NSRect)titleRectForBounds:(NSRect)frame {
    CGFloat stringHeight = self.attributedStringValue.size.height;
    NSRect titleRect = [super titleRectForBounds:frame];
    CGFloat oldOriginY = frame.origin.y;
    titleRect.origin.y = frame.origin.y + (frame.size.height - stringHeight) / 2.0;
    titleRect.size.height = titleRect.size.height - (titleRect.origin.y - oldOriginY);
    return titleRect;
}
- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    [super drawInteriorWithFrame:[self titleRectForBounds:cellFrame] inView:controlView];
}
@end
