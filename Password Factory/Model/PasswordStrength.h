//
//  PasswordStrength.h
//  Password Factory
//
//  Created by Cristiana Yambo on 12/4/15.
//  Copyright © 2015 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordStrength : NSObject
-(double)getStrengthForPasswordType:(int)passwordType
                           password:(NSString *)password;
@end
