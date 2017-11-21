//
//  TodayViewController.h
//  Password Factory Widget
//
//  Created by Cristiana Yambo on 8/17/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StrengthBox.h"

@interface TodayViewController : NSViewController

@property (weak) IBOutlet NSTextField *passwordField;

- (IBAction)generatePassword:(id)sender;
- (IBAction)copyPassword:(id)sender;
- (IBAction)backToApp:(id)sender;

@property (weak) IBOutlet StrengthBox *strengthBox;
@property (weak) IBOutlet NSPopUpButton *passwordType;
- (IBAction)changePasswordType:(NSPopUpButton *)sender;
- (IBAction)zoomPassword:(id)sender;
@end
