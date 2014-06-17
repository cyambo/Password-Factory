//
//  StatusView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 6/17/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "StatusView.h"
@interface StatusView ()
@property (nonatomic, assign) BOOL willClose;
@property (nonatomic, strong) NSPopover *popover;

@end
@implementation StatusView

-(id)initWithMvc:(MasterViewController *)mvc {
    self = [super init];
    self.mvc = mvc;
    self.willClose = NO;
    [self _setupPopover];
    return self;
}
- (void)drawRect:(NSRect)rect
{

    NSRect fillRect = CGRectOffset(rect, 0, 1); //changing fill size so it doesn't fall below menubar
    NSImage *statusIcon;
    //fills in blue if the item is clicked - stays that way until close
    if (![self.popover isShown] || self.willClose) {
        [[NSColor clearColor] set];
        statusIcon = [NSImage imageNamed:@"menu-icon"];

    } else {
       [[NSColor selectedMenuItemColor] set];
        statusIcon = [NSImage imageNamed:@"menu-icon-inv"];
    }
    
    NSRectFill(fillRect);
    //needs offset so that icon will fit properly
    fillRect = CGRectInset(rect, 7, 3);

    [statusIcon drawInRect:fillRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)mouseDown:(NSEvent *)event {
    NSLog(@"Mouse down event");

    if (![self.popover isShown]) {

        [self.popover showRelativeToRect:self.frame
                                  ofView:self
                           preferredEdge:NSMinYEdge];
    } else {
        [self.popover performClose:self];
    }
    [self setNeedsDisplay:YES];
    
}
- (void)_setupPopover
{
    if (!self.popover) {
        self.popover = [[NSPopover alloc] init];
        self.popover.contentViewController = self.mvc;
        self.popover.contentSize = (CGSize)self.mvc.view.frame.size;
        self.popover.behavior = NSPopoverBehaviorTransient;
        [self.popover setDelegate:self];
    }
}
//using willClose and didClose because without willClose the status icon
//change happens after close which looks weird, willClose makes it disappear immediately
-(void)popoverWillClose:(NSNotification *)notification {
    self.willClose = YES;
    [self setNeedsDisplay:YES];
}
-(void)popoverDidClose:(NSNotification *)notification {
    self.willClose = NO;
    NSLog(@"CLOSEEEE");
    [self setNeedsDisplay:YES];
}
@end
