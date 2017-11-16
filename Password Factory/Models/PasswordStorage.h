//
//  PasswordStorage.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "constants.h"
#import "Passwords+CoreDataProperties.h"

@interface PasswordStorage : NSObject <NSFetchedResultsControllerDelegate>
+(instancetype) get;
@property (nonatomic, assign) NSUInteger maximumPasswordsStored;
-(NSUInteger)count;
-(void)storePassword:(NSString *)password strength:(float)strength type:(PFPasswordType)type;
-(Passwords *)passwordAtIndex:(NSUInteger)index;
-(void)setSortDescriptor:(NSSortDescriptor *)sortDescriptor;
-(void)loadSavedData;
-(void)deleteAllEntities;
@end
