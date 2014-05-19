//
//  PreferencesWindow.h
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASShortcutView.h"



@interface PreferencesWindow : NSWindow <NSTextFieldDelegate>
@property (weak) IBOutlet NSButton *colorPasswordText;
@property (weak) IBOutlet NSColorWell *uppercaseTextColor;
@property (weak) IBOutlet NSColorWell *lowercaseTextColor;
@property (weak) IBOutlet NSColorWell *numbersColor;
@property (weak) IBOutlet NSColorWell *symbolsColor;
- (IBAction)changeColor:(id)sender;
@property (weak) IBOutlet NSButton *automaticallyClearClipboard;
@property (weak) IBOutlet NSSlider *clearTime;
@property (weak) IBOutlet NSTextField *clearTimeLabel;
- (IBAction)changeClearTime:(id)sender;


- (IBAction)autoClearChange:(id)sender;
+ (NSColor*)colorWithHexColorString:(NSString*)inColorString;

@property (nonatomic, weak) IBOutlet MASShortcutView *shortcutView;


@end
