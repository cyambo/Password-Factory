//
//  PasswordTypesViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"
@interface PasswordTypesViewController : NSViewController
- (NSDictionary *)getPasswordSettings;
@property (nonatomic, assign) PFPasswordType passwordType;
@property (weak) IBOutlet NSButton *useSymbols;
@property (weak) IBOutlet NSButton *avoidAmbiguous;

@property (weak) IBOutlet NSSlider *passwordLengthSlider;
@property (weak) IBOutlet NSTextField *passwordLengthText;
- (IBAction)changeLength:(id)sender;

@property (weak) IBOutlet NSTextField *patternText;




@end
