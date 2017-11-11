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

@interface PasswordTypesViewController () <NSTextFieldDelegate>

@property (nonatomic, assign) NSUInteger passwordLength;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) PasswordFactoryConstants *c;

@end

@implementation PasswordTypesViewController

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.passwordLength = 0;
    self.c = [PasswordFactoryConstants get];
    return self;
}
-(void)viewWillAppear {

    self.prefix = @"";
    if([self.delegate isKindOfClass:[PasswordController class]]) {
        self.prefix = [[(PasswordController *)self.delegate getNameForPasswordType:self.passwordType] lowercaseString];
    }

    if (self.passwordLengthSlider) {
        //setting the max password length
        NSUInteger length = [self getPasswordLength]; //but we have to get the original length
        float maxValue = [[NSUserDefaults standardUserDefaults] floatForKey:@"maxPasswordLength"];
        self.passwordLengthSlider.maxValue = maxValue;
        //if our length is greater than the max, set it to max
        if (length > maxValue) {
            length = floor(maxValue);
            [[NSUserDefaults standardUserDefaults] setFloat:(float)length forKey:@"maxPasswordLength"];
        }
        [self.passwordLengthSlider setIntValue:(int)length]; //and set it back because the changing of maxValue messes up the slider
    }
    [self setupPopUpButtons];
    [self changeLength:nil];
}

/**
 Fills in the popup buttons with defaults from PF Constants
 */
-(void)setupPopUpButtons {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if (self.caseTypeMenu) {
        [self.caseTypeMenu removeAllItems];
        for(int i = 0; i < self.c.caseTypeIndex.count; i++){
            PFCaseType t = [(NSNumber *)self.c.caseTypeIndex[i] integerValue];
            //don't display title case in random because it doesn't make sense
            if (self.passwordType == PFRandomType && t == PFTitleCase) {
                continue;
            }
            [self.caseTypeMenu addItemWithTitle:[self.c getNameForCaseType:t]];
            [self.caseTypeMenu itemAtIndex:i].tag = t;
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
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //Generates different password formats based upon the selected tab
    //set modifiers
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([self.avoidAmbiguous isKindOfClass:[NSButton class]]) {
        settings[@"avoidAmbiguous"] = @([d boolForKey:@"randomAvoidAmbiguous"]);
    }
    if ([self.useSymbols isKindOfClass:[NSButton class]]) {
        settings[@"useSymbols"] = @([d boolForKey:@"randomUseSymbols"]);
    }
    if ([self.useEmoji isKindOfClass:[NSButton class]]) {
        settings[@"useEmoji"] = @([d boolForKey:@"randomUseEmoji"]);;
    }
    if ([self.useNumbers isKindOfClass:[NSButton class]]) {
        settings[@"useNumbers"] = @([d boolForKey:@"randomUseNumbers"]);;
    }
    settings[@"passwordLength"] = @([self getPasswordLength]);
    switch (self.passwordType) {
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
            settings[@"advancedSource"] = @((PFPasswordType)self.advancedSource.selectedTag);
            break;
    }
    return settings;
}
-(NSUInteger)getPasswordLength {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"passwordLength"];
}
-(PFCaseType)getCaseType {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSString *name = [NSString stringWithFormat:@"%@CaseTypeIndex",self.prefix];
    NSUInteger index = [d integerForKey:name];
    return [self.c getCaseTypeByIndex:index];
}
-(PFSeparatorType)getSeparatorType {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
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
        NSEvent *event = [[NSApplication sharedApplication] currentEvent];
        if (event.type == NSLeftMouseUp) {
            //TODO: store password here
            NSLog(@"STORE");
        }
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
        [[NSUserDefaults standardUserDefaults] setObject:pattern forKey:@"userPattern"]; // update defaults because setting the text does not update bindings
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
 Gets the passphrase separator type and adds the type to the shared defaults
 
 @return separator type
 */
//- (PFSeparatorType)getPassphraseSeparatorType {
//    PFSeparatorType type = (PFSeparatorType)[(NSButtonCell *)[self.passphraseSeparatorRadio selectedCell] tag];
//    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"passphraseSeparatorTagShared"];
//    return type;
//}

/**
 Gets the passphrase case type and adds it to the shared defaults
 
 @return case type
 */
//- (PFCaseType)getPassphraseCaseType {
//    int type = (int)[(NSButtonCell *)[self.passphraseCaseRadio selectedCell] tag];
//    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"passphraseCaseTypeTagShared"];
//    return type;
//}

/**
 Gets the pronounceable separator type and adds it to the shared defaults
 
 @return separator type
 */
//- (PFSeparatorType)getPronounceableSeparatorType {
//    PFSeparatorType type = (PFSeparatorType)[(NSButtonCell *)[self.pronounceableSeparatorRadio selectedCell] tag];
//    [[DefaultsManager sharedDefaults] setInteger:type forKey:@"pronounceableSeparatorTagShared"];
//    return  type;
//
//}

@end
