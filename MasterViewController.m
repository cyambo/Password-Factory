//
//  MasterViewController.m
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import "MasterViewController.h"
#import "BBPasswordStrength.h"

static NSString* symbols;
static NSString* upperCase;
static NSString* lowerCase;
static NSString* nonAmbiguousUpperCase;
static NSString* nonAmbiguousLowerCase;

@interface MasterViewController ()
@property (weak) IBOutlet NSTextField *passwordField;
@property (nonatomic, strong) NSMutableString *currentRange;
@property (nonatomic, assign) NSInteger passwordLength;
@property (weak) IBOutlet NSButton *useSymbols;
@property (weak) IBOutlet NSButton *mixedCase;
@property (weak) IBOutlet NSButton *avoidAmbiguous;
@property (weak) IBOutlet NSSlider *passwordLengthSlider;
@property (weak) IBOutlet NSTextField *passwordLengthLabel;
@property (weak) IBOutlet NSTextField *passwordStrengthLabel;
@property (weak) IBOutlet NSLevelIndicator *passwordStrengthLevel;

@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
        [self setStatics];
    }
    return self;
}
- (void)awakeFromNib {
    [self getPasswordLength];
}
- (IBAction)changeLength:(id)sender {
    [self getPasswordLength];
}
- (IBAction)generateAction:(id)sender {
    [self generatePassword];
}


- (void)getPasswordLength{
    self.passwordLength = [[self passwordLengthSlider] integerValue];
    [self.passwordLengthLabel setStringValue:[NSString stringWithFormat:@"%i",(int)self.passwordLength]];
    [self generatePassword];
    
    
}
- (void)generatePassword {
    NSString *password = [self generateRandom];
    [self.passwordField setStringValue: password];
    [self setPasswordStrength:password];
    
    
}
- (void)setPasswordStrength:(NSString *)password {
    BBPasswordStrength *strength = [[BBPasswordStrength alloc] initWithPassword:password];
    double ct = strength.crackTime;
    //[10**2, 10**4, 10**6, 10**8, Infinity].
    int i;
    for (i=0;i<11; i++){
        ct = ct/10.0;
        
        if(ct <=1){
            NSLog(@"%0.2f",ct);
            break;
        }
        
    }
    i--;
    if (i<0) { i = 0;}
    [self.passwordStrengthLabel setStringValue:[NSString stringWithFormat:@"%0.2f,,%i",ct,i]];
    [self.passwordStrengthLevel setIntegerValue:i];
}
- (NSString *)generateRandom {
    [self setCharacterRange];
    NSMutableString *curr = [[NSMutableString alloc] init];
    for(int i=0;i<self.passwordLength;i++){
        int at = arc4random() % [self.currentRange length];
        char charAt = [self.currentRange characterAtIndex:at];
        [curr appendFormat:@"%c",charAt];
        
        
    }

    return curr;

}
- (void)setCharacterRange {
    NSMutableString *tmp = [[NSMutableString alloc] init];
    if ([self.useSymbols state]) {
        [tmp appendString:symbols];
    }
    if ([self.avoidAmbiguous state]) {
        [tmp appendString:nonAmbiguousLowerCase];
    } else {
        [tmp appendString:lowerCase];
    }
    if ([self.mixedCase state]) {
        if ([self.avoidAmbiguous state]) {
            [tmp appendString:nonAmbiguousUpperCase];
        } else {
            [tmp appendString:upperCase];
        }
    }
    self.currentRange = [self removeDuplicateChars:tmp];
}
- (void)setStatics {
    symbols = @"!@#$%^&*(){}[];:.\"<>?/\\-_+=|\'";
    upperCase = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    lowerCase = @"abcdefghijklmnopqrstuvwxyz";
    nonAmbiguousUpperCase = @"ABCDEFGHJKLMNPQRSTUVWXYZ";
    nonAmbiguousLowerCase = @"abcdefghijkmnpqrstuvwxyz";
 
}
- (NSMutableString *)removeDuplicateChars:(NSString *)input {

    NSMutableSet *seenCharacters = [NSMutableSet set];
    NSMutableString *result = [NSMutableString string];
    [input enumerateSubstringsInRange:NSMakeRange(0, input.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if (![seenCharacters containsObject:substring]) {
            [seenCharacters addObject:substring];
            [result appendString:substring];
        }
    }];
    return result;
}
@end
