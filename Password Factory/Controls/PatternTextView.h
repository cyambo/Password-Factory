//
//  PatternTextView.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/28/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PatternTextView : NSTextView <NSTextViewDelegate>
-(void)addText:(NSString *)text;
-(void)resetText:(NSString *)text;
@end
