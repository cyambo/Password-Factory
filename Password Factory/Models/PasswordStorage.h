//
//  PasswordStorage.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"
@interface PasswordStorage : NSObject
+(instancetype) get;
@property (nonatomic, assign) NSUInteger maximumPasswordsStored;
-(NSUInteger)count;
-(void)storePassword:(NSString *)password strength:(float)strength type:(PFPasswordType)type;
-(NSArray *)passwordAtIndex:(NSUInteger)index;
@end
