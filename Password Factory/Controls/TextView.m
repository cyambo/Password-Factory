//
//  TextView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/30/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "TextView.h"
#import "DefaultsManager.h"
@implementation TextView
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setMaxSize:NSMakeSize(FLT_MAX, self.frame.size.height)];
    [self setHorizontallyResizable:YES];
    [self.textContainer setWidthTracksTextView:NO];
    [self.textContainer setContainerSize:NSMakeSize(FLT_MAX, self.frame.size.height)];
    return self;
}
-(void)awakeFromNib {
    [self setFont:[NSFont systemFontOfSize:self.textSize]];
}
-(NSDictionary *)getTextAttributes {
    return @{
             NSFontAttributeName: [NSFont systemFontOfSize:self.textSize]
             };
}
-(void)setDefaults {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    if(self.defaultsKey != nil && self.defaultsKey.length) {
        if (![self.textStorage.string isEqualToString:[d stringForKey:self.defaultsKey]]) {
            [d setObject:self.textStorage.string forKey:self.defaultsKey];
        }
    }
}
-(void)appendText:(NSString *)text {
    if (text != nil && text.length) {
        NSDictionary *attributes = [self getTextAttributes];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        [self.textStorage appendAttributedString:string];
        [self setDefaults];
    }
}
-(void)setText:(NSString *)text {
    if(text == nil) {
        text = @"";
    }
    NSDictionary *attributes = [self getTextAttributes];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.textStorage setAttributedString:string];
    [self setDefaults];
}
@end
