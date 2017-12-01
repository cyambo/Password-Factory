//
//  ScrollView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/30/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "ScrollView.h"
#import "DefaultsManager.h"
#import "Utilities.h"
@implementation ScrollView
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    [d addObserver:self forKeyPath:@"AppleInterfaceStyle" options:NSKeyValueObservingOptionNew context:NULL];
    return self;
}
-(void)awakeFromNib {
    [self setupColors];
}
-(void)setupColors {
    self.backgroundColor = [Utilities getBackgroundColor];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //if changed to dark mode update the display
    if([keyPath isEqualToString:@"AppleInterfaceStyle"]) {
        [self setupColors];
    }
}
@end

