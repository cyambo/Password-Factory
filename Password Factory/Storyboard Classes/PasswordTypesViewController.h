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
- (void)controlChanged:(PFPasswordType)type settings:(NSDictionary *)settings;
- (NSString *)generatePassword:(PFPasswordType)type withSettings:(NSDictionary *)settings;
- (NSString *)getNameForPasswordType: (PFPasswordType)type;
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

- (IBAction)selectSeparatorType:(id)sender;
@property (weak) IBOutlet NSPopUpButton *separatorTypeMenu;

- (IBAction)selectCaseType:(id)sender;
@property (weak) IBOutlet NSPopUpButton *caseTypeMenu;
- (IBAction)changedAdvancedSource:(NSPopUpButton *)sender;

@property (weak) IBOutlet NSPopUpButton *advancedSource;
@property (weak) IBOutlet NSSlider *advancedTruncate;
@property (weak) IBOutlet NSButton *advancedReplaceAmbiguous;
@property (weak) IBOutlet NSTextField *advancedPrefixPattern;
@property (weak) IBOutlet NSTextField *advancedPostfixPattern;
@property (weak) IBOutlet NSTextField *advancedFindRegex;
@property (weak) IBOutlet NSTextField *advancedReplaceRegex;
@property (weak) IBOutlet NSStepper *advancedSymbolCasePercentStepper;
@property (weak) IBOutlet NSStepper *advancedAccentedCasePercentStepper;

- (IBAction)changeAdvancedStepper:(NSStepper *)sender;

- (IBAction)changeAdvancedTruncate:(NSSlider *)sender;
@property (weak) IBOutlet NSTextField *advancedTruncateText;




@end
