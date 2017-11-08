//
//  PasswordTypesViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "constants.h"


@class PasswordTypesViewController;
@protocol PasswordTypesViewControllerDelegate <NSObject>
-(void)controlChanged:(PFPasswordType)type settings:(NSDictionary *)settings;
@end
@interface PasswordTypesViewController : NSViewController
@property (nonatomic, weak) id <PasswordTypesViewControllerDelegate> delegate;
- (NSDictionary *)getPasswordSettings;
@property (nonatomic, assign) PFPasswordType passwordType;

- (IBAction)changeOptions:(id)sender;
@property (weak) IBOutlet NSButton *useNumbers;
@property (weak) IBOutlet NSButton *useSymbols;
@property (weak) IBOutlet NSButton *avoidAmbiguous;
@property (weak) IBOutlet NSButton *useEmoji;

@property (weak) IBOutlet NSSlider *passwordLengthSlider;
@property (weak) IBOutlet NSTextField *passwordLengthText;
- (IBAction)changeLength:(id)sender;

@property (weak) IBOutlet NSTextField *patternText;
@property (weak) IBOutlet NSPopUpButton *insertMenu;
- (IBAction)selectInsertMenuItem:(id)sender;


- (IBAction)changeCaseType:(id)sender;
@property (weak) IBOutlet NSButton *caseTypeUpperCase;
@property (weak) IBOutlet NSButton *caseTypeLowerCase;
@property (weak) IBOutlet NSButton *caseTypeMixedCase;
@property (weak) IBOutlet NSButton *caseTypeTitleCase;

- (IBAction)changeSeparatorType:(id)sender;
@property (weak) IBOutlet NSButton *noSeparator;
@property (weak) IBOutlet NSButton *hyphenSeparator;
@property (weak) IBOutlet NSButton *spaceSeparator;
@property (weak) IBOutlet NSButton *underscoreSeparator;
@property (weak) IBOutlet NSButton *numberSeparator;
@property (weak) IBOutlet NSButton *symbolSeparator;
@property (weak) IBOutlet NSButton *characterSeparator;
@property (weak) IBOutlet NSButton *emojiSeparator;
@property (weak) IBOutlet NSButton *randomSeparator;
@end
