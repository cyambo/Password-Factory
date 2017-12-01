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
/**
 Initializes textview so that it only scrolls horizontally

 @param coder default
 @return self
 */
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setMaxSize:NSMakeSize(FLT_MAX, self.frame.size.height)];
    [self setHorizontallyResizable:YES];
    [self.textContainer setWidthTracksTextView:NO];
    [self.textContainer setContainerSize:NSMakeSize(FLT_MAX, self.frame.size.height)];
    return self;
}

/**
 Sets the font size based upon ibdesignable
 */
-(void)awakeFromNib {
    [self setFont:[NSFont systemFontOfSize:self.textSize]];
}

/**
 Gets the attributes used for all text in view

 @return Attribute dictionary
 */
-(NSDictionary *)getTextAttributes {
    return @{
             NSFontAttributeName: [NSFont systemFontOfSize:self.textSize]
             };
}

/**
 Sets the string value of the text view the defaultsKey
 */
-(void)setDefaults {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    if(self.defaultsKey != nil && self.defaultsKey.length) {
        if (![self.textStorage.string isEqualToString:[d stringForKey:self.defaultsKey]]) {
            [d setObject:self.textStorage.string forKey:self.defaultsKey];
        }
    }
}

/**
 Adds text to the view

 @param text text to add
 */
-(void)appendText:(NSString *)text {
    if (text != nil && text.length) {
        text = [NSString stringWithFormat:@"%@%@",self.textStorage.string,text];
        [self setText:text];
        [self setDefaults];
    }
}

/**
 Sets the text view text

 @param text text to set
 */
-(void)setText:(NSString *)text {
    if(text == nil) {
        text = @"";
    }
    //remove all newlines because they don't make sense in the password field or pattern field
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSDictionary *attributes = [self getTextAttributes];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.textStorage setAttributedString:string];
    [self setDefaults];
}

@end
