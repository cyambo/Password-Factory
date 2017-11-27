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
@implementation ColorTextPreview


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setupView];
    return self;
}
-(void)setupView {
    [self setWantsLayer:YES];
    self.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[NSColor colorWithWhite:0.0 alpha:0.3] CGColor];
    self.layer.cornerRadius = 5.0;
}
-(void)viewWillDraw {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    if (self.defaultsKey) {
        [self setTextColor];
        [d addObserver:self forKeyPath:self.defaultsKey options:NSKeyValueObservingOptionNew context:NULL];
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //don't do anything if the change is null
    if (change[@"new"] == [NSNull null]) {
        return;
    }
    [self setTextColor];
    
}
-(void)setTextColor {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    self.textColor = [[d stringForKey:self.defaultsKey] colorWithHexColorString];
}

@end
