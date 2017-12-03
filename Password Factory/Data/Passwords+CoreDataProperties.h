//
//  Passwords+CoreDataProperties.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//
//

#import "Passwords+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Passwords (CoreDataProperties)

+ (NSFetchRequest<Passwords *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *password;
@property (nonatomic) float strength;
@property (nonatomic) int16_t type;
@property (nullable, nonatomic, copy) NSDate *time;

@end

NS_ASSUME_NONNULL_END
