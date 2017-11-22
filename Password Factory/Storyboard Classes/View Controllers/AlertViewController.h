//
//  AlertViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/22/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AlertViewController : NSViewController
@property (nonatomic, strong) NSString *defaultsKey;
@property (weak) IBOutlet NSTextField *alertText;
@property (weak) IBOutlet NSButton *hideCheckbox;
@property (weak) NSWindow *currentWindow;
- (IBAction)changeHideCheckbox:(NSButton *)sender;
- (IBAction)clickedOK:(NSButton *)sender;

@end
