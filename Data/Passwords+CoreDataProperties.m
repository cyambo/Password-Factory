//
//  Passwords+CoreDataProperties.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//
//

#import "Passwords+CoreDataProperties.h"

@implementation Passwords (CoreDataProperties)

+ (NSFetchRequest<Passwords *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Passwords"];
}

@dynamic password;
@dynamic strength;

@end
