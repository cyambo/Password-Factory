//
//  OnlyIntegerFormatter.h
//  Password Factory
//
//  Created by Cristiana Yambo on 9/5/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnlyIntegerFormatter : NSNumberFormatter

@property (assign, nonatomic) IBInspectable NSInteger minValue;
@property (assign, nonatomic) IBInspectable NSInteger maxValue;

@end
