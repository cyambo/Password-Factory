//
//  PasswordTypesViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordTypesViewController.h"
#import "PasswordController.h"
@interface PasswordTypesViewController () <NSTextFieldDelegate>

@property (nonatomic, assign) NSUInteger passwordLength;
@property (nonatomic, strong) NSString *prefix;

@end

@implementation PasswordTypesViewController

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.passwordLength = 0;
    return self;
}
-(void)viewWillAppear {

    self.prefix = @"";
    if([self.delegate isKindOfClass:[PasswordController class]]) {
        self.prefix = [[(PasswordController *)self.delegate getNameForPasswordType:self.passwordType] lowercaseString];
    }
    [self changeLength:nil];
}

/**
 Gets the password generation settings based upon controls

 @return dictionary of settings
 */
-(NSDictionary *)getPasswordSettings {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //Generates different password formats based upon the selected tab
    //set modifiers
    if ([self.avoidAmbiguous isKindOfClass:[NSButton class]]) {
        settings[@"avoidAmbiguous"] = @([self.avoidAmbiguous state]);
    }
    if ([self.useSymbols isKindOfClass:[NSButton class]]) {
        settings[@"useSymbols"] = @([self.useSymbols state]);
    }
    if ([self.useEmoji isKindOfClass:[NSButton class]]) {
        settings[@"useEmoji"] = @([self.useEmoji state]);
    }
    if ([self.useNumbers isKindOfClass:[NSButton class]]) {
        settings[@"useNumbers"] = @([self.useNumbers state]);
    }
    settings[@"passwordLength"] = @([self getPasswordLength]);
    switch (self.passwordType) {
        case PFRandomType: //random
            settings[@"caseType"] = @((PFCaseType)self.caseTypeMenu.selectedItem.tag);
            break;
        case PFPatternType: //pattern
            settings[@"patternText"] = self.patternText.stringValue;
            break;
        case PFPronounceableType: //pronounceable
            settings[@"caseType"] = @((PFCaseType)self.caseTypeMenu.selectedItem.tag);
            settings[@"separatorType"] = @((PFSeparatorType)self.separatorTypeMenu.selectedItem.tag);
            break;
        case PFPassphraseType: //passphrase:
            settings[@"caseType"] = @((PFCaseType)self.caseTypeMenu.selectedItem.tag);
            settings[@"separatorType"] = @((PFSeparatorType)self.separatorTypeMenu.selectedItem.tag);
            break;
    }
    return settings;
}
-(NSUInteger)getPasswordLength {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"passwordLength"];
}

/**
 Called when length slider is updated and sets all related lentgh values

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
