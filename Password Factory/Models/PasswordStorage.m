//
//  PasswordStorage.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PasswordStorage.h"
@interface PasswordStorage ()
@property (nonatomic, strong) NSMutableArray *passwords;
@property (nonatomic, strong) NSMutableArray *sortedPasswords;
@property (nonatomic, strong) NSSortDescriptor *sort;
@end
@implementation PasswordStorage
+(instancetype) get {
    static PasswordStorage *ps = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^ {
        ps = [[PasswordStorage alloc] init];
    });
    return ps;
}
-(instancetype)init {
    self = [super init];
    self.maximumPasswordsStored = 100;
    self.passwords = [[NSMutableArray alloc] init];
    return self;
}
-(void)storePassword:(NSString *)password strength:(float)strength type:(PFPasswordType)type {
    NSDictionary *p = @{@"password":password, @"strength":@(strength), @"type":@(type)};
    [self.passwords insertObject:p atIndex:0];
    if (self.passwords.count > self.maximumPasswordsStored) {
        [self.passwords removeLastObject];
    }
}
-(NSUInteger)count {
    return self.passwords.count;
}
-(NSDictionary *)passwordAtIndex:(NSUInteger)index {
    if (index < [self count]) {
        return self.passwords[index];
    }
    return nil;
}
-(void)setSortDescriptor:(NSSortDescriptor *)sortDescriptor {
    self.sort = sortDescriptor;
    self.sortedPasswords = self.passwords;
    NSLog(@"%@", sortDescriptor.key);
    if ([sortDescriptor.key isEqualToString:@"type"]) {
        
    } else if ([sortDescriptor.key isEqualToString:@"strength"]) {
        
    } else if ([sortDescriptor.key isEqualToString:@"password"]) {
        
    }
}
@end
