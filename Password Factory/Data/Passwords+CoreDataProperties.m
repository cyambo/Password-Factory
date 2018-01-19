//
//  Passwords+CoreDataProperties.m
//  
//
//  Created by Cristiana Yambo on 1/18/18.
//
//

#import "Passwords+CoreDataProperties.h"

@implementation Passwords (CoreDataProperties)

+ (NSFetchRequest<Passwords *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Passwords"];
}

@dynamic length;
@dynamic password;
@dynamic passwordID;
@dynamic strength;
@dynamic time;
@dynamic type;
@dynamic synced;

@end
