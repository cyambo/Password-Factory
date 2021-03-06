//
//  PasswordTypesViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordTypesViewController.h"
#import "PasswordController.h"
#import "PasswordFactoryConstants.h"
#import "PasswordFactory.h"
#import "DefaultsManager.h"
#import "PasswordStorage.h"
#import "TypeIcons.h"
#import "StrengthControl.h"
#import "Utilities.h"
#import "SecureRandom.h"
#import "ColorUtilities.h"
@interface PasswordTypesViewController () <NSTextFieldDelegate, DefaultsManagerDelegate>

@property (nonatomic, assign) NSInteger passwordLength;
@property (nonatomic, assign) NSInteger truncateLength;
@property (nonatomic, strong) PasswordFactoryConstants *c;
@property (nonatomic, strong) DefaultsManager *d;
@property (nonatomic, strong) NSRegularExpression *findRegex;
@property (nonatomic, assign) BOOL didViewAppear;
@property (nonatomic, assign) NSUInteger previousAccentedCasePercent;
@property (nonatomic, assign) NSUInteger previousSymbolCasePercent;
@end

@implementation PasswordTypesViewController

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.passwordLength = -1;
    self.truncateLength = -1;
    self.c = [PasswordFactoryConstants get];
    self.d = [DefaultsManager get];
    self.didViewAppear = NO;
    [self.d observeDefaults:self keys:@[@"maxStoredPasswords", @"storePasswords", @"colorPasswordText", @"upperTextColor", @"lowerTextColor", @"symbolTextColor", @"defaultTextColor", @"extendedTextColor", @"cloudKitZoneStartTime"]];
    return self;
}

-(void)viewWillAppear {
    self.didViewAppear = NO;
    //setting the max password length
    NSUInteger maxPasswordLength = [self.d integerForKey:@"maxPasswordLength"];
    if (self.passwordLengthSlider) {
        NSUInteger length = [self.delegate getPasswordLength:self.passwordType]; //but we have to get the original length
        
        self.passwordLengthSlider.maxValue = maxPasswordLength;
        //if our length is greater than the max, set it to max
        if (length > maxPasswordLength) {
            length = maxPasswordLength;
            NSString *key = [NSString stringWithFormat:@"%@PasswordLength",[[self.c getNameForPasswordType:self.passwordType] lowercaseString]];
            [self.d setInteger:maxPasswordLength forKey:key];
        }
        [self.passwordLengthSlider setIntegerValue:length]; //and set it back because the changing of maxValue messes up the slider
    }
    //setting the advanced truncate max to maxPasswordLength
    if(self.advancedTruncate) {
        self.advancedTruncate.maxValue = maxPasswordLength;
        NSUInteger truncateLength = [self.delegate getTruncateLength];
        if (truncateLength > maxPasswordLength) {
            truncateLength = maxPasswordLength;
            [self.d setInteger:maxPasswordLength forKey:@"advancedTruncateAt"];
        }
        [self.advancedTruncate setIntegerValue:truncateLength];
        [self changeAdvancedTruncate:nil];
    }
    [self setupPopUpButtons];
    [self changeLength:nil];
    if (self.storedPasswordTable) {
        //reload the table data because stored passwords may have been updated
        [[PasswordStorage get] loadSavedData];
        [self.storedPasswordTable reloadData];
        
        //select the first one if we have any data
        [self selectFromStored:0];
        
    }

    [self setAdvancedRegex];
    
}
-(void)viewDidAppear {
    self.didViewAppear = YES;
}

/**
 Selects an item at index from stored password table
 
 @param index index to select
 */
-(void)selectFromStored:(NSUInteger)index {
    if (!self.didViewAppear) {
        index = 0; //only select the first one until the view is actually on screen
    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:index];
    [self.storedPasswordTable selectRowIndexes:set byExtendingSelection:false];
    [self.storedPasswordTable scrollRowToVisible:index];
}

/**
 Selects random item from the stored password table
 */
-(void)selectRandomFromStored {
    PasswordStorage *s = [PasswordStorage get];
    if ([s count]) {
        uint index = [SecureRandom randomInt:(uint)[s count]];
        [self selectFromStored:index];
    } else {
        //nothing in the table so just call the delegate to set the password and strength to nothing
        [self callDelegate];
    }
    
}
/**
 Fills in the popup buttons with defaults from PF Constants
 */
-(void)setupPopUpButtons {
    
    if (self.caseTypeMenu) {
        [self.caseTypeMenu removeAllItems];
        
        for(int i = 0; i < self.c.caseTypeIndex.count; i++){
            PFCaseType t = [(NSNumber *)self.c.caseTypeIndex[i] integerValue];
            //don't display title case in random or advanced because it doesn't make sense
            if ((self.passwordType == PFRandomType || self.passwordType == PFAdvancedType) && t == PFTitleCase) {
                continue;
            }
            [self.caseTypeMenu addItemWithTitle:[self.c getNameForCaseType:t]];
            [self.caseTypeMenu itemAtIndex:i].tag = t;
        }
        //add a no change item to advanced type
        if (self.passwordType == PFAdvancedType) {
            [self.caseTypeMenu insertItemWithTitle:NSLocalizedString(@"noChangeMessage", comment: @"No Change") atIndex:0];
            [self.caseTypeMenu itemAtIndex:0].tag = 0;
        }
        NSString *name = [NSString stringWithFormat:@"%@CaseTypeIndex",self.prefix];
        [self.caseTypeMenu selectItemAtIndex:[self.d integerForKey:name]];
    }
    if (self.separatorTypeMenu) {
        [self.separatorTypeMenu removeAllItems];
        for(int i = 0; i < self.c.separatorTypeIndex.count; i++){
            PFSeparatorType t = [(NSNumber *)self.c.separatorTypeIndex[i] integerValue];
            [self.separatorTypeMenu addItemWithTitle:[self.c getNameForSeparatorType:t]];
            [self.separatorTypeMenu itemAtIndex:i].tag = t;
        }
        NSString *name = [NSString stringWithFormat:@"%@SeparatorTypeIndex",self.prefix];
        [self.separatorTypeMenu selectItemAtIndex:[self.d integerForKey:name]];
    }
    if (self.insertMenu) {
        [self.insertMenu removeAllItems];
        [self.insertMenu addItemWithTitle:NSLocalizedString(@"insertMessage", comment: @"Insert")];
        for(int i = 0; i < self.c.patternTypeIndex.count; i++) {
            PFPatternTypeItem t = [(NSNumber *)self.c.patternTypeIndex[i] integerValue];
            [self.insertMenu addItemWithTitle:[self.c getNameForPatternTypeItem:t]];
            [self.insertMenu itemAtIndex:i].tag = t;
        }
    }
}

/**
 Called when length slider is updated and sets all related length values
 
 @param sender default sender
 */
- (IBAction)changeLength:(id)sender {
    if (self.passwordLengthSlider != nil) {
        if ([self.delegate getPasswordLength:self.passwordType] != self.passwordLength) {
            self.passwordLength = [self.delegate getPasswordLength:self.passwordType];
            [self.passwordLengthText setStringValue:[NSString stringWithFormat:@"%lu",self.passwordLength]];
            //do not call the delegate if sender is nil
            if (sender != nil) {
                [self.d setBool:YES forKey:@"activeControl"];
                //magic to call doneRepeatingAction when mouse up happens
                [NSObject cancelPreviousPerformRequestsWithTarget:self];
                NSArray *objectToSend = @[@([sender floatValue]),[self.delegate getPasswordLengthKey:self.passwordType]];
                [self performSelector: @selector(doneRepeatingAction:) withObject: objectToSend afterDelay: 0.0];
                [self callDelegate];
            }
        }
    }
}


/**
 Called when slider is finished

 @param object array with slider value as first, and key as second
 */
-(void)doneRepeatingAction:(NSArray *)object {
    NSNumber *value = object[0];
    NSString *key = object[1];
    [self.d setBool:NO forKey:@"activeControl"];
    [self.d storeObject:value forKey:key];
}

/**
 Called when checkboxes are updaed
 
 @param sender default sender
 */
- (IBAction)changeOptions:(id)sender {
    [self callDelegate];
}

/**
 Inserts a value into the pattern field
 
 @param sender default sender
 */
- (IBAction)selectInsertMenuItem:(id)sender {
    if(self.insertMenu.indexOfSelectedItem != 0) {
        char toInsert = [self.insertMenu.selectedItem.title characterAtIndex:0];
        [self.patternText appendText:[NSString stringWithFormat:@"%c",toInsert]];
        [self.insertMenu selectItemAtIndex:0]; //select the first again
    }
}

/**
 Sets the separator type based upon the dropdown
 
 @param sender default sender
 */
- (IBAction)selectSeparatorType:(id)sender {
    [self callDelegate];
}

/**
 Sets the case type based upon the dropdown
 
 @param sender default sender
 */
- (IBAction)selectCaseType:(id)sender {
    [self callDelegate];
}

/**
 delegate method for text field
 
 @param obj default sender
 */
- (void)controlTextDidChange:(NSNotification *)obj {
    //if our regex has changed validate it
    if (obj.object == self.advancedFindRegex) {
        [self setAdvancedRegex];
    }
    [self callDelegate];
}
/**
 Called when source is changed in advanced
 
 @param sender default sender
 */
- (IBAction)changedAdvancedSource:(NSPopUpButton *)sender {
    [self callDelegate];
}

/**
 Calls our delegate method with settings
 */
-(void)callDelegate {
    if(self.delegate) {
        [self.delegate controlChanged:self.passwordType];
    }
}

/**
 Called when one of the steppers on the advanced page is clicked
 
 @param sender default sender
 */
- (IBAction)changeAdvancedStepper:(NSStepper *)sender {
    //do not call the delegate if the previous value was the same
    //this is so that when you hit 0 or 100 it doesn't keep repeating
    
    [self.d setBool:YES forKey:@"activeControl"];
    NSString *key;
    if(sender == self.advancedSymbolCasePercentStepper) {
        if (sender.integerValue == self.previousSymbolCasePercent) {
            return;
        } else {
            key = @"advancedSymbolCasePercent";
            self.previousSymbolCasePercent = sender.integerValue;
        }
    } else if (sender == self.advancedAccentedCasePercentStepper) {
        if (sender.integerValue == self.previousAccentedCasePercent) {
            return;
        } else {
            key = @"advancedAccentedCasePercent";
            self.previousAccentedCasePercent = sender.integerValue;
        }
    }
    //magic to call doneRepeatingAction when mouse up happens
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSArray *objectToSend = @[@([sender floatValue]),key];
    [self performSelector: @selector(doneRepeatingAction:) withObject: objectToSend afterDelay: 0.0];
    [self callDelegate];
}

/**
 Called when truncate slider is changed
 
 @param sender default sender
 */
- (IBAction)changeAdvancedTruncate:(NSSlider *)sender {
    if ([self.delegate getTruncateLength] != self.truncateLength) {
        self.truncateLength = [self.delegate getTruncateLength];
        if(self.truncateLength) {
            [self.advancedTruncateText setStringValue:[NSString stringWithFormat:@"%lu",self.truncateLength]];
        } else {
            [self.advancedTruncateText setStringValue:@"None"];
        }
        //do not call the delegate if sender is nil
        if (sender != nil) {
            [self.d setBool:YES forKey:@"activeControl"];
            //magic to call sliderDone when mouse up happens
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            NSArray *objectToSend = @[@([sender floatValue]),@"advancedTruncateAt"];
            [self performSelector: @selector(doneRepeatingAction:) withObject: objectToSend afterDelay: 0.0];
            [self callDelegate];
        }
    }
}

/**
 Checks to see if the regex is valid, and if it is not, turn the regex field red
 */
-(void)setAdvancedRegex {
    NSError *error = NULL;
    NSString *r = [self.advancedFindRegex stringValue];
    NSColor *color = [NSColor blackColor];
    self.findRegex = nil;
    if (r.length) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:r options:0 error:&error];
        if (error) {
            color = [NSColor redColor];
        } else {
            self.findRegex = regex;
        }
    }
    self.advancedFindRegex.textColor = color;
}
#pragma mark Table View
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    int c = (int)[[PasswordStorage get] count];
    int max = (int)[[DefaultsManager get] integerForKey:@"maxStoredPasswords"];
    if (c > max) {
        return max;
    }
    return c;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *c;
    Passwords *p = [[PasswordStorage get] passwordAtIndex:row];
    
    if ([tableColumn.identifier isEqualToString:@"Type"]) {
        c = [tableView makeViewWithIdentifier:@"PasswordTypeCell" owner:nil];
        PFPasswordType type = p.type;
        c.imageView.image = [TypeIcons getAlternateTypeIcon:type];
    } else if ([tableColumn.identifier isEqualToString:@"Password"]) {
        c = [tableView makeViewWithIdentifier:@"PasswordCell" owner:nil];
        NSInteger fontSize = [(NSNumber *)[[c.textField font].fontDescriptor objectForKey:NSFontSizeAttribute] integerValue];
        NSAttributedString *passwordString = [Utilities colorText:p.password size:fontSize];
        [c.textField setAttributedStringValue:passwordString];
    } else if ([tableColumn.identifier isEqualToString:@"Strength"]) {
        c = [tableView makeViewWithIdentifier:@"StrengthCell" owner:nil];
        float strength = p.strength;
        [c.textField setStringValue: [NSString stringWithFormat:@"%d",(int)(strength * 100)]];
        NSColor *strengthColor = [ColorUtilities getStrengthColor:strength];
        NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithAttributedString:c.textField.attributedStringValue];
        [a addAttribute:NSForegroundColorAttributeName value:strengthColor range:NSMakeRange(0, a.length)];
        [c.textField setAttributedStringValue:a];
    }
    
    
    return c;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self.d setInteger:self.storedPasswordTable.selectedRow forKey:@"storedPasswordTableSelectedRow"];
    [self callDelegate];
}
- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    PasswordStorage *s = [PasswordStorage get];
    if (tableView.sortDescriptors.count) {
        s.sortDescriptor = tableView.sortDescriptors[0];
    } else {
        s.sortDescriptor = nil;
    }
    [tableView reloadData];
    [self selectFromStored:0]; //select the first
}
- (void)observeValue:(NSString * _Nullable)keyPath change:(NSDictionary * _Nullable)change {
    if (self.storedPasswordTable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.storedPasswordTable reloadData];
        });
    }
}

@end
