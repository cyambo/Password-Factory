//
//  PasswordTypesViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/6/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordTypesViewController.h"

@interface PasswordTypesViewController () <NSTextFieldDelegate>
@property (nonatomic, assign) NSUInteger maxPasswordLength;
- (PFSeparatorType)getSeparatorType;
- (PFCaseType)getCaseType;
@end

@implementation PasswordTypesViewController

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    return self;
}
-(NSDictionary *)getPasswordSettings {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //Generates different password formats based upon the selected tab
    //set modifiers
    if ([self.avoidAmbiguous isKindOfClass:[NSButton class]]) {
        settings[@"avoidAmbiguous"] = @([self.avoidAmbiguous state]);
    }
    if ([self.useSymbols isKindOfClass:[NSButton class]]) {
        settings[@"useSymbols"] = @([self.avoidAmbiguous state]);
    }
    settings[@"passwordLength"] = @(self.maxPasswordLength);
    switch (self.passwordType) {
        case PFRandomType: //random
            settings[@"caseType"] = @([self getCaseType]);
            break;
        case PFPatternType: //pattern
            settings[@"patternText"] = self.patternText.stringValue;
            break;
        case PFPronounceableType: //pronounceable
            settings[@"caseType"] = @([self getCaseType]);
            settings[@"separatorType"] = @([self getSeparatorType]);
            break;
        case PFPassphraseType: //passphrase:
            settings[@"caseType"] = @([self getCaseType]);
            settings[@"separatorType"] = @([self getSeparatorType]);
            break;
    }
    return settings;
}
-(NSUInteger)getMaxPasswordLength {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"passwordLength"];
}
-(PFCaseType)getCaseType {
    return PFLower;
}
-(PFSeparatorType)getSeparatorType {
    return PFHyphenSeparator;
}

- (IBAction)changeLength:(id)sender {
    NSLog(@"%d",  [[NSUserDefaults standardUserDefaults] integerForKey:@"passwordLength"]);
}

- (void)getPasswordLength{
//    NSUInteger prevLength = self.passwordLength;
//    self.passwordLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"passwordLength"];
//    NSLog(@"PREV %d, %d", prevLength, self.passwordLength);
//    if (prevLength != self.passwordLength) { //do not change password unless length changes
//        [self generatePassword];
//    }
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
