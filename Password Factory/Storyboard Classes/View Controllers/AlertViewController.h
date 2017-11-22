//
//  AlertViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/22/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlertWindowController.h"
@interface AlertViewController : NSViewController
@property (nonatomic, strong) NSString *defaultsKey;
@property (weak) IBOutlet NSTextField *alertText;
@property (weak) IBOutlet NSButton *hideCheckbox;
@property (weak) AlertWindowController *alertWindowController;
- (IBAction)changeHideCheckbox:(NSButton *)sender;
- (IBAction)clickedOK:(NSButton *)sender;
- (IBAction)clickedCancel:(NSButton *)sender;
@property (weak) IBOutlet NSButton *cancelButton;

@end
