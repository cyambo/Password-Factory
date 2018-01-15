//
//  NSString+sha1.m
//  Password Factory
//
//  Created by Cristiana Yambo on 1/13/18.
//  Copyright © 2018 Cristiana Yambo. All rights reserved.
//

#import "NSString+sha1.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (sha1)
- (NSString *)sha1
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end
