//
//  BoxView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/26/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "BoxView.h"
@interface BoxView ()
@property (nonatomic, strong) NSTextField *titleText;
@end
@implementation BoxView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    [self setWantsLayer:YES];
    self.layer.backgroundColor = [[NSColor colorWithWhite:0.0 alpha:0.02] CGColor];
    self.layer.cornerRadius = 10.0;
    self.titleText = [[NSTextField alloc] init];
    [self addSubview:self.titleText];
    self.titleText.backgroundColor = [NSColor clearColor];
    self.titleText.bordered = NO;
    self.titleText.selectable = NO;
    [self.titleText setAlphaValue:0.3];
    [self.titleText setFont:[NSFont systemFontOfSize:10]];
    return self;
}
-(void)viewWillDraw {
    [self.titleText setStringValue:self.boxTitle];
    CGFloat yvalue = self.frame.size.height - 15;
    NSRect frame = NSMakeRect(11,yvalue, 240, 14);
    [self.titleText setFrame:frame];
    
}
@end
