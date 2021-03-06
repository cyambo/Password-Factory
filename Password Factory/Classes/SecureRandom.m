//
//  SecureRandom.m
//  Password Factory
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "SecureRandom.h"
@import SBObjectiveCWrapper;

@implementation SecureRandom
/**
 Generates a cryptographic random number
 
 @param limit upper limit of number
 @return random uint
 */
+(uint)randomInt:(uint)limit {
    if (limit == 0) {
        return 0;
    }
    int32_t randomNumber = 0;
    uint result = SecRandomCopyBytes(kSecRandomDefault, 4, (uint8_t*) &randomNumber);
    if(result == 0) {
        uint n =  randomNumber % limit;
        if (n > limit) {
            return limit; //if for some reason n is over the limit, return the limit (should never reach this)
        } else {
            return n;
        }
    } else {
        SBLogError(@"SecRandomCopyBytes Failed");
    }
    return 1;
}
@end
