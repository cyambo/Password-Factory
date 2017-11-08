//
//  StyleKit.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/7/17.
//  Copyright © 2017 Password Factory. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//

#import <Cocoa/Cocoa.h>



typedef enum : NSInteger
{
    StyleKitResizingBehaviorAspectFit, //!< The content is proportionally resized to fit into the target rectangle.
    StyleKitResizingBehaviorAspectFill, //!< The content is proportionally resized to completely fill the target rectangle.
    StyleKitResizingBehaviorStretch, //!< The content is stretched to match the entire target rectangle.
    StyleKitResizingBehaviorCenter, //!< The content is centered in the target rectangle, but it is NOT resized.

} StyleKitResizingBehavior;

extern NSRect StyleKitResizingBehaviorApply(StyleKitResizingBehavior behavior, NSRect rect, NSRect target);


@interface StyleKit : NSObject

// Drawing Methods
+ (void)drawStrengthMeterWithStrengthColor: (NSColor*)strengthColor strength: (CGFloat)strength size: (NSSize)size;
+ (void)drawStrengthMeterWithFrame: (NSRect)targetFrame resizing: (StyleKitResizingBehavior)resizing strengthColor: (NSColor*)strengthColor strength: (CGFloat)strength size: (NSSize)size;
+ (void)drawPreferencesButton;
+ (void)drawMenuIcon;
+ (void)drawStrengthBoxWithStrengthColor: (NSColor*)strengthColor;

// Generated Images
+ (NSImage*)imageOfPreferencesButton;
+ (NSImage*)imageOfMenuIcon;
+ (NSImage*)imageOfAdvancedType;
+ (NSImage*)imageOfPassphraseType;
+ (NSImage*)imageOfPatternType;
+ (NSImage*)imageOfPronounceableType;
+ (NSImage*)imageOfRandomType;

@end
