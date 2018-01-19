//
//  PasswordTextView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/30/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordTextView.h"
#import "Utilities.h"
#import "AppDelegate.h"
#import "StyleKit.h"
@implementation PasswordTextView


/**
 Sets the text of the view and highlights based upon settings

 @param text text to set
 */
-(void)setText:(NSString *)text {
    [super setText:text];
    //color the text if necessary
    NSAttributedString *s = [Utilities colorText:self.textStorage.string size:self.textSize];
    NSArray *ranges = self.selectedRanges;
    [self.textStorage setAttributedString:s];
    self.selectedRanges = ranges;
}

- (NSTouchBar *)makeTouchBar {
    NSTouchBar *bar = [[NSTouchBar alloc] init];
    bar.delegate = self;
    
    // Set the default ordering of items.
    bar.defaultItemIdentifiers =
    @[@"ZoomButton",@"TypeSelection",@"GenerateButton",@"CopyButton"];
    
    return bar;
}
- (nullable NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier {
    AppDelegate *d = [NSApplication sharedApplication].delegate;
    if ([identifier isEqualToString:@"ZoomButton"]) {
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:@"ZoomButton"];
        NSButton *button = [NSButton buttonWithTitle:@"Zoom"
                                              target:self
                                              action:@selector(zoomPassword)];
        button.image = [StyleKit imageOfZoomWithZoomStroke:[NSColor whiteColor]];
        touchBarItem.view = button;
        touchBarItem.customizationLabel = @"Zoom";
        
        return touchBarItem;
    }
    if ([identifier isEqualToString:@"TypeSelection"]) {
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:@"TypeSelection"];
        touchBarItem.view = d.masterViewController.touchBarTypeControl;
        touchBarItem.customizationLabel = @"Select Type";
        return touchBarItem;
    }
    if ([identifier isEqualToString:@"GenerateButton"]) {
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:@"GenerateButton"];
        NSButton *button = [NSButton buttonWithTitle:@"Generate"
                                              target:self
                                              action:@selector(generatePassword)];
        touchBarItem.customizationLabel = @"Generate";
        touchBarItem.view = button;
        return touchBarItem;
    }
    if ([identifier isEqualToString:@"CopyButton"]) {
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:@"CopyButton"];
        NSButton *button = [NSButton buttonWithTitle:@"Copy"
                                              target:self
                                              action:@selector(copyToClipboard)];
        touchBarItem.customizationLabel = @"Copy";
        touchBarItem.view = button;
        return touchBarItem;
    }
    return nil;
}
-(void)zoomPassword {
    AppDelegate *d = [NSApplication sharedApplication].delegate;
    [d.masterViewController zoomPassword:nil];
}
-(void)generatePassword {
    AppDelegate *d = [NSApplication sharedApplication].delegate;
    [d.masterViewController generatePassword];
}
-(void)copyToClipboard {
    AppDelegate *d = [NSApplication sharedApplication].delegate;
    [d.masterViewController copyToClipboard:nil];
}
@end
