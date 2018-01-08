//
//  PasswordStorage.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//



#import "PasswordStorage.h"
#import "constants.h"
#import "DefaultsManager.h"
#import "NSString+UnicodeLength.h"
#import <SyncKit/QSCloudKitSynchronizer+CoreData.h>
#ifndef IOS
#import "AppDelegate.h"
#endif
@interface PasswordStorage () <QSCoreDataChangeManagerDelegate>
@property (nonatomic, strong) NSMutableArray *passwords;
@property (nonatomic, strong) NSMutableArray *sortedPasswords;
@property (nonatomic, strong) NSSortDescriptor *sort;
@property (nonatomic, strong) NSPersistentContainer *container;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) DefaultsManager *d;
@property (nonatomic, strong) NSString *prev;
@property (nonatomic, strong) QSCloudKitSynchronizer *synchronizer;
@end
@implementation PasswordStorage

/**
 Singleon Get

 @return PasswordStorage singleton
 */
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
    self.d = [DefaultsManager get];
#ifdef IS_MACOS
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:SharedDefaultsAppGroup];
#else
    NSURL *containerURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
#endif
    containerURL = [containerURL URLByAppendingPathComponent:@"database.sqlite"];
    NSPersistentStoreDescription *description = [[NSPersistentStoreDescription alloc] initWithURL:containerURL];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"StoredPasswordModel" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.container = [[NSPersistentContainer alloc] initWithName:@"StoredPasswordModel" managedObjectModel:model];
    self.container.persistentStoreDescriptions = @[description];
    [self.container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull storeDescription, NSError * _Nullable error) {
        self.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        
        self.synchronizer = [QSCloudKitSynchronizer cloudKitSynchronizerWithContainerName:iCloudContainer managedObjectContext:self.container.viewContext changeManagerDelegate:self];

        if(error) {
#ifndef IOS
            AppDelegate *d = [NSApplication sharedApplication].delegate;
            [d.alertWindowController displayError:error.localizedDescription code:PFCoreDataLoadError];
#endif
        }
    }];
    //set to sort with newest on top
    self.sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO selector:@selector(compare:)];
    [self loadSavedData];
    [self deleteOverMaxItems];
    [self.synchronizer subscribeForUpdateNotificationsWithCompletion:^(NSError *error) {
        NSLog(@"UPDATE YO");
    }];
    return self;
}

/**
 Stores the password in Core Data

 @param password Password to be stored
 @param strength strength of password
 @param type PFPasswordType of password
 */
-(void)storePassword:(NSString *)password strength:(float)strength type:(PFPasswordType)type {
    if (self.prev != nil && [password isEqualToString:self.prev]) { //getting duplicates from bug in observer on ios, so, just return
        return;
    }
    self.prev = password;
    if (password && password.length) { //don't store 0 length passwords
        //setup the core data class
        Passwords *pw = [[Passwords alloc] initWithContext:self.container.viewContext];
        pw.password = password;
        pw.strength = strength;
        pw.type = type;
        pw.length = [password getUnicodeLength];
        pw.time = [NSDate date];
        //save it
        [self saveContext];
        [self loadSavedData];
        [self deleteOverMaxItems];
    }
}

/**
 Deletes any items over the max number of stored passwords set
 */
-(void)deleteOverMaxItems {
    self.maximumPasswordsStored = [self.d integerForKey:@"maxStoredPasswords"];
    if ([self count] > self.maximumPasswordsStored) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Passwords"];
        
        fetchRequest.fetchLimit = [self count] - self.maximumPasswordsStored;
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]];
        
        NSError *error = nil;
        NSArray *items = [self.container.viewContext executeFetchRequest:fetchRequest error:&error];
        if (error.localizedDescription) {
#ifndef IOS
            AppDelegate *d = [NSApplication sharedApplication].delegate;
            [d.alertWindowController displayError:error.localizedDescription code:PFCoreDataDeleteOverMaxFetchError];
#endif
        }
        for(Passwords *p in items) {
            [self.container.viewContext deleteObject:p];
        }
        [self saveContext];
    }
}

/**
 Saves any updates
 */
-(void)saveContext {
    if (self.container.viewContext.hasChanges) {
        NSError *error = nil;
        [self.container.viewContext save:&error];
        if (error.localizedDescription) {
#ifndef IOS
            AppDelegate *d = [NSApplication sharedApplication].delegate;
            [d.alertWindowController displayError:error.localizedDescription code:PFCoreDataSaveFailedError];
#endif
        }
    }
    [self synchronizeWithRemote];
}
-(void)synchronize:(BOOL)callDelegate {
    [self.synchronizer synchronizeWithCompletion:^(NSError *error) {
        if (error) {
            NSLog(@"SYNC ERR ERR %@",error.localizedDescription);
        } else {
            [self loadSavedData];
            [self deleteOverMaxItems];
            if (callDelegate) {
                if (self.delegate != nil) {

                    [self.delegate receivedUpdatedData];
                }
            }
        }
    }];
}
-(void)synchronizeWithRemote {
    [self synchronize:false];
}
-(void)receivedUpdatedData {
    [self synchronize:true];
}
/**
 Loads saved passwords with sorting
 */
-(void)loadSavedData {
    NSFetchRequest *r = [Passwords fetchRequest];
    if (self.sort) {
        r.sortDescriptors = @[self.sort];
    } else {
        r.sortDescriptors = @[];
    }
    [r setFetchBatchSize:20];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:r managedObjectContext:self.container.viewContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    if(error.localizedDescription) {
#ifndef IOS
        AppDelegate *d = [NSApplication sharedApplication].delegate;
        [d.alertWindowController displayError:error.localizedDescription code:PFCoreDataLoadSavedDataFailedError];
#endif
    }
}

/**
 Gets the number of objects stored

 @return number of objects
 */
-(NSUInteger)count {
    NSUInteger c = 0;
    if (self.fetchedResultsController.sections[0]) {
       c = self.fetchedResultsController.sections[0].numberOfObjects;
    }
    return c;
}

/**
 Gets the password at the current index

 @param index 0 based index of passwords
 @return Passwords object
 */
-(Passwords *)passwordAtIndex:(NSUInteger)index {
    if (index < [self count]) {
        NSUInteger indexArr[] = {0,index};
        NSIndexPath *p = [[NSIndexPath alloc] initWithIndexes:indexArr length:2];
        return [self.fetchedResultsController objectAtIndexPath:p];
    } else {
        //return nil if we are over count
        return nil;
    }
}

/**
 Deletes the item at index

 @param index index of item to delete
 */
-(void)deleteItemAtIndex:(NSUInteger)index {
    Passwords *curr = [self passwordAtIndex:index];
    [self.container.viewContext deleteObject:curr];
    [self saveContext];
    [self loadSavedData];
    
}
/**
 Changes the sort descriptor

 @param sortDescriptor to sort
 */
-(void)setSortDescriptor:(NSSortDescriptor *)sortDescriptor {
    self.sort = sortDescriptor;
    [self loadSavedData];
}

/**
 Deletes everything from the Core Data db
 */
-(void)deleteAllEntities {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Passwords"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    NSError *error = nil;
    [self.container.viewContext executeRequest:delete error:&error];
    if (error.localizedDescription) {
#ifndef IOS
        AppDelegate *d = [NSApplication sharedApplication].delegate;
        [d.alertWindowController displayError:error.localizedDescription code:PFCoreDataDeleteAllFailedError];
#endif
    }
    [self synchronizeWithRemote];
    [self loadSavedData];
}

/**
 Called when max storage amount was changed
 */
-(void)changedMaxStorageAmount {
    [self loadSavedData];
    [self deleteOverMaxItems];
}

- (void)changeManager:(QSCoreDataChangeManager *)changeManager didImportChanges:(NSManagedObjectContext *)importContext completion:(void (^)(NSError *))completion {
    __block NSError *error = nil;
    [importContext performBlockAndWait:^{
        [importContext save:&error];
    }];
    
    if (!error) {
        [self.container.viewContext performBlockAndWait:^{
            [self.container.viewContext save:&error];
        }];
    } else {
        NSLog(@"DID IMPORT ERR %@",error.localizedDescription);
    }
    completion(error);
}

- (void)changeManagerRequestsContextSave:(QSCoreDataChangeManager *)changeManager completion:(void (^)(NSError *))completion {
    __block NSError *error = nil;
    [self.container.viewContext performBlockAndWait:^{
        [self.container.viewContext save:&error];
    }];
    if (error) {
        NSLog(@"REQ ERR %@",error.localizedDescription);
    }
    completion(error);
}

@end
