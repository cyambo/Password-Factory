//
//  BoxView.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/26/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 Rounded box view for preferences
 */
IB_DESIGNABLE
@interface BoxView : NSView
@property (nonatomic, strong) IBInspectable NSString *boxTitle;
@end
