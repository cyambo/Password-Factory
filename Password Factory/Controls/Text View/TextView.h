//
//  TextView.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/30/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TextView : NSTextView
@property (nonatomic, assign) IBInspectable NSUInteger textSize;
@property (nonatomic, strong) IBInspectable NSString *defaultsKey;
-(void)appendText:(NSString *)text;
-(void)setText:(NSString *)text;
-(void)setDefaults;
-(NSDictionary *)getTextAttributes;
@end
