//
//  BoxView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/26/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "BoxView.h"
#import "TextField.h"
@interface BoxView ()
@property (nonatomic, strong) NSTextField *titleText;
@end
@implementation BoxView

-(void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self setupView];
}
-(void)setupView {
    [self addTitleView];
    [self setWantsLayer:YES];
    
    self.layer.backgroundColor = [[NSColor colorWithWhite:0.0 alpha:0.02] CGColor];
    self.layer.cornerRadius = 10.0;
    self.layer.borderColor = [[NSColor colorWithWhite:0.0 alpha:0.03] CGColor];
    self.layer.borderWidth = 0.5;
    
    [self.layer setMasksToBounds:NO];
    
    [self.titleText setStringValue:self.boxTitle];
    CGFloat yvalue = self.frame.size.height - 15;
    CGFloat width = self.frame.size.width - 30;
    NSRect frame = NSMakeRect(15,yvalue, width, 14);
    [self.titleText setFrame:frame];
    NSRect f = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height - 14);
    [self.layer setBounds:f];
}
-(void)addTitleView {
    if(![self viewWithTag:9999]) {
        self.boxTitle = @"";
        self.titleText = [[NSTextField alloc] init];
        self.titleText.tag  = 9999;
        self.titleText.backgroundColor = [NSColor clearColor];
        self.titleText.bordered = NO;
        self.titleText.selectable = NO;
        [self.titleText setAlphaValue:0.4];
        [self.titleText setFont:[NSFont systemFontOfSize:10]];
        [self.titleText setAlignment:NSTextAlignmentLeft];
        [self addSubview:self.titleText];
    }
}

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    [self setupView];
    return self;
}
-(void)prepareForInterfaceBuilder {
    [self setupView];
}
-(void)setNeedsLayout:(BOOL)needsLayout {
    [super setNeedsLayout:needsLayout];
    [self setupView];
}
@end
