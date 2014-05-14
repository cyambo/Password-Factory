//
//  PreferencesWindow.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/13/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "PreferencesWindow.h"
#import "NSColor+NSColorHexadecimalValue.h"
@implementation PreferencesWindow

- (void)awakeFromNib {
    
    

    [self loadPreferencesFromPlist];
    [self updatePrefsUI];
    
}
-(void)updatePrefsUI {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    self.colorPasswordText.state = (BOOL)[d objectForKey:@"colorPasswordText"];
    self.automaticallyClearClipboard.state = (BOOL)[d objectForKey:@"clearClipboard"];
    
    if (!self.automaticallyClearClipboard.state) {
        [self.clearTime setEnabled:NO];
    }
    [self endEditingFor:self.clearTime];

    [self.clearTime setIntegerValue:[d integerForKey:@"clearClipboardTime"]];
    [self.clearTimeLabel setIntValue:(int)[d integerForKey:@"clearClipboardTime"]];

    [self.uppercaseTextColor setColor: [PreferencesWindow colorWithHexColorString:[d objectForKey:@"upperTextColor"]]];
    [self.lowercaseTextColor setColor: [PreferencesWindow colorWithHexColorString:[d objectForKey:@"lowerTextColor"]]];
    [self.symbolsColor setColor: [PreferencesWindow colorWithHexColorString:[d objectForKey:@"symbolTextColor"]]];
    [self.numbersColor setColor: [PreferencesWindow colorWithHexColorString:[d objectForKey:@"numberTextColor"]]];
    

    
}
- (void)controlTextDidChange:(NSNotification *)obj {
    if (obj.object == self.clearTime) {
        NSUserDefaults  *d = [NSUserDefaults standardUserDefaults];
        [d setInteger:[self.clearTime intValue] forKey:@"clearClipboardTime"];
    }
}

-(void)loadPreferencesFromPlist {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSDictionary *p = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    //taking plist and filling in defaults if none set
    for (NSString *k in p) {
        if (![d objectForKey:k]) {
            if ([k isEqualToString:@"colorPasswordText"] ||
                [k isEqualToString:@"clearClipboard"]) {
                [d setBool:(BOOL)[p objectForKey:k] forKey:k];
            } else if ([k isEqualToString:@"clearClipboardTime"]){

                [d setInteger:[[p objectForKey:k] intValue]  forKey:k];
            } else {
                [d setObject:[p objectForKey:k] forKey:k];
            }
            
        }
    }
}
// From http://stackoverflow.com/questions/8697205/convert-hex-color-code-to-nscolor
+ (NSColor*)colorWithHexColorString:(NSString*)inColorString
{
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits
    
    result = [NSColor
              colorWithCalibratedRed:(CGFloat)redByte / 0xff
              green:(CGFloat)greenByte / 0xff
              blue:(CGFloat)blueByte / 0xff
              alpha:1.0];
    return result;
}
- (IBAction)changeColor:(id)sender {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([sender isEqualTo:self.uppercaseTextColor]) {
           [d setObject:[self.uppercaseTextColor.color hexadecimalValueOfAnNSColor] forKey:@"upperTextColor"];
    } else if ([sender isEqualTo:self.lowercaseTextColor]) {
        [d setObject:[self.lowercaseTextColor.color hexadecimalValueOfAnNSColor] forKey:@"lowerTextColor"];
    } else if ([sender isEqualTo:self.numbersColor]) {
        [d setObject:[self.numbersColor.color hexadecimalValueOfAnNSColor] forKey:@"numberTextColor"];
    } else if ([sender isEqualTo:self.symbolsColor]) {
        [d setObject:[self.symbolsColor.color hexadecimalValueOfAnNSColor] forKey:@"symbolTextColor"];
    } else if ([sender isEqualTo: self.colorPasswordText]){
        [d setBool:(BOOL)self.colorPasswordText.state forKey:@"colorPasswordText"];
    }
}
- (IBAction)changeClearTime:(id)sender {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [self.clearTimeLabel setIntValue:(int)[self.clearTime integerValue]];
    [d setInteger:[self.clearTime integerValue] forKey:@"clearClipboardTime"];
}

- (IBAction)autoClearChange:(id)sender {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([sender isEqualTo: self.automaticallyClearClipboard]) {
        [d setBool:(BOOL)self.automaticallyClearClipboard.state forKey:@"clearClipboard"];
    } else {
        [d setInteger:[self.clearTime intValue] forKey:@"clearClipboardTime"];
    }
}
@end
