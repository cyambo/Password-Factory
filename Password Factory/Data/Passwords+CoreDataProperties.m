//
//  Passwords+CoreDataProperties.m
//  
//
//  Created by Cristiana Yambo on 12/22/17.
//
//

#import "Passwords+CoreDataProperties.h"

@implementation Passwords (CoreDataProperties)

+ (NSFetchRequest<Passwords *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Passwords"];
}

@dynamic password;
@dynamic strength;
@dynamic time;
@dynamic type;
@dynamic length;

@end
