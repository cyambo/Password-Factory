//
//  MenuPopover.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/24/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "MenuPopover.h"

@implementation MenuPopover 
-(NSTouchBar *)makeTouchBar {
    return [self.contentViewController makeTouchBar];

}
@end
