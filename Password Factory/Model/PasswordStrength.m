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
@implementation PasswordStrength
-(double)getStrengthForPasswordType:(int)passwordType password:(NSString *)password {
    BBPasswordStrength *strength = [[BBPasswordStrength alloc] initWithPassword:password];

    //playing around with numbers to make a good scale
    double ct = log10(strength.crackTime);
    //tweaking output based on password type
    if (passwordType == PFTabRandom) {
        ct = (ct/40)*100;
    } else if (passwordType == PFTabPassphrase) {
        ct = (ct/20)*100;
        
    } else {
        ct = (ct/40)*100;
    }
    
    if (ct > 100) {ct = 100;}
    return ct;
}
@end
