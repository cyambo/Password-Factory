//
//  SecureRandom.h
//  Password Factory
//
//  Created by Cristiana Yambo on 12/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SecureRandom : NSObject
+(uint)randomInt:(uint)limit;
@end
