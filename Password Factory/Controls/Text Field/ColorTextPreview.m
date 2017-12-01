//
//  ColorTextExample.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/27/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "ColorTextPreview.h"
#import "DefaultsManager.h"
#import "NSString+ColorWithHexColorString.h"
#import "NSColor+NSColorHexadecimalValue.h"
#import "Utilities.h"

@interface ColorTextPreview ()
@property (nonatomic, strong) NSColor *layerBackgroundColor;
@end
@implementation ColorTextPreview


-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setupView];
    return self;
}

/**
 Sets up the view for display
 */
-(void)setupView {
    [self setWantsLayer:YES];
    self.backgroundColor = [NSColor clearColor];
    [self initBackgroundColor];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[NSColor colorWithWhite:0.0 alpha:0.3] CGColor];
    self.layer.cornerRadius = 5.0;
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    [d addObserver:self forKeyPath:@"AppleInterfaceStyle" options:NSKeyValueObservingOptionNew context:NULL];
    
}
-(void)initBackgroundColor {
    //use the dark mode colors when in dark mode for an accurate preview
    self.layerBackgroundColor = [Utilities getBackgroundColor];
    self.layer.backgroundColor = [self.layerBackgroundColor CGColor];
}

-(void)awakeFromNib {
    [self initBackgroundColor];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    if (self.defaultsKey) {
        [self setTextColor];
        [d addObserver:self forKeyPath:self.defaultsKey options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //if changed to dark mode update the display
    if([keyPath isEqualToString:@"AppleInterfaceStyle"]) {
        [self initBackgroundColor];
        [self setNeedsDisplay];
        return;
    }
    //don't do anything if the change is null
    if (change[@"new"] == [NSNull null]) {
        return;
    }
    
    [self setTextColor];
    
}
-(void)setTextColor {
    DefaultsManager *d = [DefaultsManager get];
    NSString *hexString = [d stringForKey:self.defaultsKey];
    NSColor *color;
    //if dark mode use color dodge on it to approximate what the colors look like in dark mode
    if ([Utilities isDarkMode]) {
        color = [Utilities dodgeColor:[hexString colorWithHexColorString] backgroundColor:self.layerBackgroundColor];
    } else {
        color = [hexString colorWithHexColorString];
    }
    self.textColor = color;
}


@end
