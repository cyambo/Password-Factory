//
//  TodayViewController.h
//  Password Factory Widget
//
//  Created by Cristiana Yambo on 8/17/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TodayViewController : NSViewController
@property (weak) IBOutlet NSTextField *passwordField;
- (IBAction)generatePassword:(id)sender;
- (IBAction)copyPassword:(id)sender;
@property (weak) IBOutlet NSComboBox *passwordType;
- (IBAction)selectPasswordType:(id)sender;

@end
