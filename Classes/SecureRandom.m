//
//  SecureRandom.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/16/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "SecureRandom.h"

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
        return randomNumber % limit;
    } else {
        NSLog(@"SecRandomCopyBytes failed for some reason");
    }
    return 1;
}

@end
