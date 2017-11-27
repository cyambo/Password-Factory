//
//  ColorTextExample.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/27/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 Previews the text color in preferences
 */
@interface ColorTextPreview : NSTextField
@property (nonatomic, strong) IBInspectable NSString *defaultsKey;
@end
