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
@interface PasswordTypesViewController () <NSTextFieldDelegate>

@property (nonatomic, assign) NSInteger passwordLength;
@property (nonatomic, assign) NSInteger truncateLength;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) PasswordFactoryConstants *c;
@property (nonatomic, strong) NSRegularExpression *findRegex;
@property (nonatomic, strong) PasswordStorage *storage;
@end

@implementation PasswordTypesViewController

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.passwordLength = -1;
    self.truncateLength = -1;
    self.c = [PasswordFactoryConstants get];
    self.storage = [PasswordStorage get];
    return self;
}
-(void)viewWillAppear {

    self.prefix = [[self.delegate getNameForPasswordType:self.passwordType] lowercaseString];
    //setting the max password length
    NSUInteger maxValue = [[DefaultsManager standardDefaults] integerForKey:@"maxPasswordLength"];
    if (self.passwordLengthSlider) {
        NSUInteger length = [self getPasswordLength]; //but we have to get the original length

        self.passwordLengthSlider.maxValue = maxValue;
        //if our length is greater than the max, set it to max
        if (length > maxValue) {
            length = maxValue;
            [[DefaultsManager standardDefaults] setInteger:maxValue forKey:@"passwordLength"];
        }
        [self.passwordLengthSlider setIntegerValue:length]; //and set it back because the changing of maxValue messes up the slider
    }
    //setting the advanced truncate max to maxPasswordLength
    if(self.advancedTruncate) {
        self.advancedTruncate.maxValue = maxValue;
        NSUInteger truncateLength = [self getTruncateLength];
        if (truncateLength > maxValue) {
            truncateLength = maxValue;
            [[DefaultsManager standardDefaults] setInteger:maxValue forKey:@"advancedTruncateAt"];
        }
        [self.advancedTruncate setIntegerValue:truncateLength];
        [self changeAdvancedTruncate:nil];
    }
    [self setupPopUpButtons];
    [self changeLength:nil];
    if (self.storedPasswordTable) {
        //reload the table data because stored passwords may have been updated
        [self.storedPasswordTable reloadData];
        if ([self.storage count]) {
            //select the first one if we have any data
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:0];
            [self.storedPasswordTable selectRowIndexes:set byExtendingSelection:false];
        }
    }
}

/**
 Fills in the popup buttons with defaults from PF Constants
 */
-(void)setupPopUpButtons {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
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
            [self.caseTypeMenu insertItemWithTitle:@"No Change" atIndex:0];
            [self.caseTypeMenu itemAtIndex:0].tag = 0;
        }
        NSString *name = [NSString stringWithFormat:@"%@CaseTypeIndex",self.prefix];
        [self.caseTypeMenu selectItemAtIndex:[d integerForKey:name]];
    }
    if (self.separatorTypeMenu) {
        [self.separatorTypeMenu removeAllItems];
        for(int i = 0; i < self.c.separatorTypeIndex.count; i++){
            PFSeparatorType t = [(NSNumber *)self.c.separatorTypeIndex[i] integerValue];
            [self.separatorTypeMenu addItemWithTitle:[self.c getNameForSeparatorType:t]];
            [self.separatorTypeMenu itemAtIndex:i].tag = t;
        }
        NSString *name = [NSString stringWithFormat:@"%@SeparatorTypeIndex",self.prefix];
        [self.separatorTypeMenu selectItemAtIndex:[d integerForKey:name]];
    }
    if (self.insertMenu) {
        [self.insertMenu removeAllItems];
        [self.insertMenu addItemWithTitle:@"Insert"];
        for(int i = 0; i < self.c.patternTypeIndex.count; i++) {
            PFPatternTypeItem t = [(NSNumber *)self.c.patternTypeIndex[i] integerValue];
            [self.insertMenu addItemWithTitle:[self.c getNameForPatternTypeItem:t]];
            [self.insertMenu itemAtIndex:i].tag = t;
        }
    }
}
/**
 Gets the password generation settings based upon controls

 @return dictionary of settings
 */
-(NSDictionary *)getPasswordSettings {
    return [self getPasswordSettingsByType:self.passwordType];
}
-(NSDictionary *)getPasswordSettingsByType:(PFPasswordType)type {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //Generates different password formats based upon the selected tab
    //set modifiers
    NSUserDefaults *d = [DefaultsManager standardDefaults];

    settings[@"avoidAmbiguous"] = @([d boolForKey:@"randomAvoidAmbiguous"]);
    settings[@"useSymbols"] = @([d boolForKey:@"randomUseSymbols"]);
    settings[@"useEmoji"] = @([d boolForKey:@"randomUseEmoji"]);
    settings[@"useNumbers"] = @([d boolForKey:@"randomUseNumbers"]);
    settings[@"passwordLength"] = @([self getPasswordLength]);
    
    switch (type) {
        case PFRandomType: //random
            settings[@"caseType"] = @([self getCaseType]);
            break;
        case PFPatternType: //pattern
            settings[@"patternText"] = [d stringForKey:@"userPattern"];
            break;
        case PFPronounceableType: //pronounceable
            settings[@"caseType"] = @([self getCaseType]);
            settings[@"separatorType"] = @([self getSeparatorType]);
        case PFPassphraseType: //passphrase:
            settings[@"caseType"] = @([self getCaseType]);
            settings[@"separatorType"] = @([self getSeparatorType]);
            break;
        case PFAdvancedType: //advanced
            [settings addEntriesFromDictionary:[self generateAdvancedPasswordSettings]];
            break;
        case PFStoredType: //stored
            settings[@"storedPassword"] = [self.storage passwordAtIndex:self.storedPasswordTable.selectedRow][@"password"];
    }
    return settings;
}

/**
 Generates the advanced password settings for password generation

 @return settings dictionary
 */
-(NSMutableDictionary *)generateAdvancedPasswordSettings {
    PFPasswordType sourceType;
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    sourceType = (PFPasswordType)self.advancedSource.selectedTag;
    //changing the prefix to the source type so that we get the proper settings
    self.prefix = [[self.delegate getNameForPasswordType:sourceType] lowercaseString];
    NSDictionary *sourceSettings = [self getPasswordSettingsByType:sourceType];
    NSString *password = [self.delegate generatePassword:sourceType withSettings:sourceSettings];
    
    settings[@"generatedPassword"] = password;
    settings[@"truncateAt"] = @([self.advancedTruncate integerValue]);
    
    //generating the prefix and the postfix
    NSString *pre = [self.advancedPrefixPattern stringValue];
    NSString *post = [self.advancedPostfixPattern stringValue];
    if (pre.length || post.length) {
        self.prefix = @"pattern";
        NSMutableDictionary *patternSettings = [[self getPasswordSettingsByType:PFPatternType] mutableCopy];
        if(pre.length) {
            patternSettings[@"patternText"] = [self.advancedPrefixPattern stringValue];
            settings[@"prefix"] = [self.delegate generatePassword:PFPatternType withSettings:patternSettings];
        }
        if(post.length) {
            patternSettings[@"patternText"] = [self.advancedPostfixPattern stringValue];
            settings[@"postfix"] = [self.delegate generatePassword:PFPatternType withSettings:patternSettings];
        }
        self.prefix = @"advanced";
    }

    settings[@"accentedCasePercent"] = @([self.advancedAccentedCasePercentStepper integerValue]);
    settings[@"symbolCasePercent"] = @([self.advancedSymbolCasePercentStepper integerValue]);
    settings[@"replaceAmbiguous"] = @([d boolForKey:@"advancedReplaceAmbiguous"]);
    //set the case type
    if(self.caseTypeMenu.selectedTag != 0) { //no change has a tag of zero
        settings[@"caseType"] = @(self.caseTypeMenu.selectedTag);
    }
    [self setAdvancedRegex];
    if( self.findRegex ) {
        settings[@"findRegex"] = self.findRegex;
        settings[@"replacePattern"] = [self.advancedReplaceRegex stringValue];
    }
    self.prefix = @"advanced"; //setting back to advanced
    return settings;
}

/**
 Gets the set password length

 @return password length
 */
-(NSUInteger)getPasswordLength {
    return [[DefaultsManager standardDefaults] integerForKey:@"passwordLength"];
}

-(NSUInteger)getTruncateLength {
    return [[DefaultsManager standardDefaults] integerForKey:@"advancedTruncateAt"];
}
/**
 Gets the case type for the selected password type

 @return PFCaseType
 */
-(PFCaseType)getCaseType {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    NSString *name = [NSString stringWithFormat:@"%@CaseTypeIndex",self.prefix];
    NSUInteger index = [d integerForKey:name];
    return [self.c getCaseTypeByIndex:index];
}

/**
 Gets the separator type for the selected password type

 @return PFSeparatorType
 */
-(PFSeparatorType)getSeparatorType {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    NSString *name = [NSString stringWithFormat:@"%@SeparatorTypeIndex",self.prefix];
    NSUInteger index = [d integerForKey:name];
    return [self.c getSeparatorTypeByIndex:index];
    
}
/**
 Called when length slider is updated and sets all related length values

 @param sender default sender
 */
- (IBAction)changeLength:(id)sender {
    if ([self getPasswordLength] != self.passwordLength) {
        self.passwordLength = [self getPasswordLength];
        [self.passwordLengthText setStringValue:[NSString stringWithFormat:@"%lu",self.passwordLength]];
        [self callDelegate];
    }
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
        NSString *pattern = [NSString stringWithFormat:@"%@%c",self.patternText.stringValue,toInsert];
        [self.patternText setStringValue:pattern];
        [[DefaultsManager standardDefaults] setObject:pattern forKey:@"userPattern"]; // update defaults because setting the text does not update bindings
        [self.insertMenu selectItemAtIndex:0];
        [self callDelegate];
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
        [self.delegate controlChanged:self.passwordType settings:[self getPasswordSettings]];
    }
}

/**
 Called when one of the steppers on the advanced page is clicked

 @param sender default sender
 */
- (IBAction)changeAdvancedStepper:(NSStepper *)sender {
    [self callDelegate];
}

/**
 Called when truncate slider is changed

 @param sender default sender
 */
- (IBAction)changeAdvancedTruncate:(NSSlider *)sender {
    if ([self getTruncateLength] != self.truncateLength) {

        self.truncateLength = [self getTruncateLength];
        if(self.truncateLength) {
            [self.advancedTruncateText setStringValue:[NSString stringWithFormat:@"%lu",self.truncateLength]];
        } else {
            [self.advancedTruncateText setStringValue:@"None"];
        }
        
        [self callDelegate];
    }
}
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
    return [self.storage count];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *c;
    NSDictionary *curr = [self.storage passwordAtIndex:row];

    if ([tableColumn.identifier isEqualToString:@"Type"]) {
        c = [tableView makeViewWithIdentifier:@"PasswordTypeCell" owner:nil];
        PFPasswordType type = [(NSNumber *)curr[@"type"] integerValue];
        c.imageView.image = [TypeIcons getAlternateTypeIcon:type];
    } else if ([tableColumn.identifier isEqualToString:@"Password"]) {
        c = [tableView makeViewWithIdentifier:@"PasswordCell" owner:nil];
        [c.textField setStringValue:curr[@"password"]];
    } else if ([tableColumn.identifier isEqualToString:@"Strength"]) {
        c = [tableView makeViewWithIdentifier:@"StrengthCell" owner:nil];
        float strength = [(NSNumber *)curr[@"strength"] floatValue];
        [c.textField setStringValue: [NSString stringWithFormat:@"%d",(int)strength]];
        NSColor *strengthColor = [StrengthControl getStrengthColorForStrength:strength/100];
        NSMutableAttributedString *a = [[NSMutableAttributedString alloc] initWithAttributedString:c.textField.attributedStringValue];
        [a addAttribute:NSForegroundColorAttributeName value:strengthColor range:NSMakeRange(0, a.length)];
        [c.textField setAttributedStringValue:a];
    }
    

    return c;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self callDelegate];
}
- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    if (tableView.sortDescriptors.count) {
        self.storage.sortDescriptor = tableView.sortDescriptors[0];
    } else {
        self.storage.sortDescriptor = nil;
    }
    [tableView reloadData];
}
@end
