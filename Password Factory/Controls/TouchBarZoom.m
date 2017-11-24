//
//  TouchBarZoom.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/24/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "TouchBarZoom.h"
#import "StyleKit.h"
@implementation TouchBarZoom
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setImage:[StyleKit imageOfZoomWithZoomStroke:[NSColor whiteColor]]];
    return self;
    
}
@end
