//
//  StatusView.h
//  Password Factory
//
//  Created by Cristiana Yambo on 6/17/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MasterViewController.h"
@interface StatusView : NSView <NSPopoverDelegate>
-(id)initWithMvc:(MasterViewController *)mvc;
-(BOOL)isVisible;

@end
