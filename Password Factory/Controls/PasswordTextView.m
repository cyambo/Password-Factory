//
//  PasswordTextView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/30/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordTextView.h"
#import "Utilities.h"
@implementation PasswordTextView

-(void)setText:(NSString *)text {
    //remove all newlines because they don't make sense in the password field
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    //color the text if necessary
    NSAttributedString *s = [Utilities colorText:text size:self.textSize];
    [self.textStorage setAttributedString:s];
}
@end
