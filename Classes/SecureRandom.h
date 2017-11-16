//
//  SecureRandom.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/16/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecureRandom : NSObject
+(uint)randomInt:(uint)limit;
@end
