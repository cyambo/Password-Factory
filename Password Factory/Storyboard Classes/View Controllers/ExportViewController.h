//
//  ExportViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/22/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
@interface ExportViewController : NSViewController
@property (weak) IBOutlet NSPopUpButton *passwordTypes;
@property (weak) IBOutlet NSTextField *exportAmount;
@property (weak) IBOutlet NSButton *exportType;
@property (weak) IBOutlet NSButton *exportStrength;
@property (weak) IBOutlet NSProgressIndicator *progress;
- (IBAction)export:(NSButton *)sender;
@property (weak) IBOutlet NSButton *exportButton;
- (IBAction)changePasswordType:(NSPopUpButton *)sender;

@end
