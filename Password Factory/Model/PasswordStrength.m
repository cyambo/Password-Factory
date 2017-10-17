//
//  PasswordStrength.m
//  Password Factory
//
//  Created by Cristiana Yambo on 12/4/15.
//  Copyright © 2015 Cristiana Yambo. All rights reserved.
//

#import "PasswordStrength.h"
#import "BBPasswordStrength.h"
#import "constants.h"

typedef NS_ENUM(NSInteger, PSApproximate) {
    PSLessThan,
    PSAbout,
    PSEqualTo,
    PSGreaterThan
};

/**
 Analyzes password and sets shows the strength of the password as a number from 1-100, also can calculate a nicely formatted string of the crack time
 */
@interface PasswordStrength ()

@property (nonatomic, strong) NSNumberFormatter* numberFormatter;
@property (nonatomic, strong) BBPasswordStrength* bbPasswordStrength;

@end
@implementation PasswordStrength

-(instancetype)init {
    self = [super init];
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    [self.numberFormatter setNumberStyle: NSNumberFormatterSpellOutStyle];
    return self;
}

/**
 Updates the password strength property which is a strength value that is from 0 to 100

 @param password Password to check
 @param withCt also calculate crack time as a string
 */
-(void)updatePasswordStrength:(NSString *)password withCrackTimeString:(BOOL)withCt {
    self.bbPasswordStrength = [[BBPasswordStrength alloc] initWithPassword:password];
    double ct = self.bbPasswordStrength.crackTime / 100;
    if (withCt) {
        [self getCrackTimeString:ct];
    }
    
    ct = log10(ct); //strength display is logarithmic
    ct /= .265; //this multiplier will give a nice scale
    self.strength = floor(ct);
    if (self.strength < 0) {
        self.strength = 0;
    } else if (self.strength > 100) {
        self.strength = 100;
    }
}

/**
 Gets a nice name for the crack time which is the number of years (or days,weeks,days,hours, minutes)

 @param crackTime the crack time
 @return a nicely formatted string
 */
-(NSString *)getCrackTimeString:(double)crackTime {
    double ct = crackTime / 60;
    NSString *s;
    PSApproximate approximate;
    //getting times that are less than a year, need to do this manually because the for loop below works in powers of ten
    //and to make the loop simpler the non-powers of ten time elements are hand written
    if ((approximate = [self checkApproximateToOne:ct]) != PSGreaterThan) {
        s = @"a minute";
    } else if ((approximate = [self checkApproximateToOne:(ct / 60)]) != PSGreaterThan) {
        s = @"an hour";
    } else if ((approximate = [self checkApproximateToOne:(ct / (60 * 24))]) != PSGreaterThan) {
        s = @"a day";
    } else if ((approximate = [self checkApproximateToOne:(ct / (60 * 24 * 7))]) != PSGreaterThan) {
        s = @"a week";
    } else if ((approximate = [self checkApproximateToOne:(ct / (60 * 24 * 30))]) != PSGreaterThan) {
        s = @"a month";
    } else if ((ct / (60 * 24 * 7 * 30 * 365)) < 1) {
        s = @"a year";
    }
    //Greater than a year
    if (s == nil) {
        ct /= (60 * 24 * 365); //crack time in years
        
        if (ct < 10) { //less than ten years
            ct = floor(ct); //get number of years
            NSNumber *f = [NSNumber numberWithInt:ct];
            s = [NSString stringWithFormat:@"%@ years",[self.numberFormatter stringFromNumber:f]]; //write out the numbers
            approximate = PSAbout; //set approximate to 'about'
        }
        else {
            //greater than ten years
            int count = 1;
            while (s == nil && count < 18) { //setting the loop to max out at 10^18, which is the highest NSNumberFormatter works with
                ct /= 10;
                if (ct < 10) {
                    int f = floor(ct);
                    //setting the exponent directly because using pow and floats does not create an exact value
                    NSNumber *num = [NSDecimalNumber decimalNumberWithMantissa:f exponent:count isNegative:NO];
                    s = [self.numberFormatter stringFromNumber:num]; //write out the numbers
                    approximate = PSAbout;
                    
                }
                count ++;
            }
            //we didn't fall out of the loop so we are less than 1e18 years
            if (s) {
                s = [NSString stringWithFormat:@"%@ years",s];
            }
        }
        //if we didn't set a string that means we are greater than 1e18 years
        if (s == nil) {
            approximate = PSGreaterThan; //so set it to greater than
            s = @"one septillion years";
        }
    }
    NSString *prefix;
    //converting approximate enum to string
    switch (approximate) {
        case PSLessThan:
            prefix = @"less than";
            break;
        case PSEqualTo:
            prefix = @"";
            break;
        case PSAbout:
            prefix = @"about";
            break;
        case PSGreaterThan:
            prefix = @"greater than";
    }
    s = [NSString stringWithFormat:@"%@ %@",prefix,s];
    self.crackTimeString = s; //set and return the string
    return self.crackTimeString;
}

/**
 returns the 'approximate' to one value, this is used to get prefix strings for time string

 @param check number approximate to 1.0
 @return PSApproximate value
 */
-(PSApproximate)checkApproximateToOne:(double)check {
    if (check < 0.8) {
        return PSLessThan;
    } if (check < 1.05 && check > 0.95) {
        return PSEqualTo;
    } else if (check < 1.2) {
        return PSAbout;
    }
    return PSGreaterThan;
}
@end
