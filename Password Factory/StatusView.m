//
//  StatusView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 6/17/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "StatusView.h"
#import "AppDelegate.h"
@interface StatusView ()
@property (nonatomic, assign) BOOL willClose;
@property (nonatomic, strong) NSPopover *popover;
@property (nonatomic, strong) MasterViewController *mvc;
@end
@implementation StatusView

-(id)initWithMvc:(MasterViewController *)mvc {
    self = [super init];
    self.mvc = mvc;

    return self;
}

- (void)drawRect:(NSRect)rect
{

    NSRect fillRect = CGRectOffset(rect, 0, 1); //changing fill size so it doesn't fall below menubar
    NSImage *statusIcon;
    //fills in blue if the item is clicked - stays that way until close
    if (![[(AppDelegate *)[NSApp delegate] window] isVisible] ) {
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
    
    NSWindow *currWindow = [(AppDelegate *)[NSApp delegate] window];
    //simple toggle if window is visible
    if (![currWindow isVisible]){
        //getting coordinates of status menu so I can place the window under it
        CGRect eventFrame = self.window.frame;

        eventFrame.size = currWindow.frame.size;
        CGRect screen = [[NSScreen mainScreen] frame];
        float xPos = eventFrame.origin.x;
        //if the window is partially offscreen then move it back onto screen
        if (xPos + eventFrame.size.width > screen.size.width ) {
            xPos -= ((xPos + eventFrame.size.width) - screen.size.width);
        }

        CGRect e = CGRectMake(xPos , eventFrame.origin.y, eventFrame.size.width, eventFrame.size.height);
        
        [currWindow setFrame:e display:YES];
        [currWindow makeKeyAndOrderFront:self];
    } else {
        [currWindow close];
    }
    [self setNeedsDisplay:YES];
    
}


@end
