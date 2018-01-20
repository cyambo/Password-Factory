//
//  PasswordStorage.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#if TARGET_OS_OSX
#else
#define IOS 1
#endif

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import  CloudKit;
#import "constants.h"
#import "Passwords+CoreDataProperties.h"
@class PasswordStorage;
@protocol PasswordStorageDelegate <NSObject>
-(void)receivedUpdatedData;
@end
@interface PasswordStorage : NSObject <NSFetchedResultsControllerDelegate>
+(instancetype) get;
@property (nonatomic, weak) id <PasswordStorageDelegate> delegate;
@property (nonatomic, assign) NSUInteger maximumPasswordsStored;
@property (class, nonatomic, assign) BOOL disableRemoteFetchChanges;
-(NSUInteger)count;
-(void)storePassword:(NSString *)password strength:(float)strength type:(PFPasswordType)type;
-(Passwords *)passwordAtIndex:(NSUInteger)index;
-(void)deleteItemAtIndex:(NSUInteger)index;
-(void)setSortDescriptor:(NSSortDescriptor *)sortDescriptor;
-(void)loadSavedData;
-(void)deleteAllEntities;
-(void)deleteAllRemoteObjects;
-(void)enableRemoteStorage:(BOOL)enabled;
-(void)changedMaxStorageAmount;
-(void)receivedUpdatedData:(CKNotification *)notification complete:(void (^)(BOOL))completionHandler;
@end
