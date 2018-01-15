//
//  PasswordStorage.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

@import  CloudKit;
#import "PasswordStorage.h"
#import "constants.h"
#import "DefaultsManager.h"
#import "NSString+UnicodeLength.h"
#import "NSString+sha1.h"

#ifndef IOS
#import "AppDelegate.h"
#endif
@interface PasswordStorage ()
@property (nonatomic, strong) NSMutableArray *passwords;
@property (nonatomic, strong) NSMutableArray *sortedPasswords;
@property (nonatomic, strong) NSSortDescriptor *sort;
@property (nonatomic, strong) NSPersistentContainer *container;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) CKContainer *cloudKitContainer;
@property (nonatomic, strong) CKDatabase *cloudKitDatabase;
@property (nonatomic, strong) CKRecordZone *cloudKitRecordZone;
@property (nonatomic, strong) DefaultsManager *d;
@property (nonatomic, strong) NSString *prev;
@property (nonatomic, assign) BOOL enableRemoteStorage;
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
        
        if(error) {
#ifndef IOS
            AppDelegate *d = [NSApplication sharedApplication].delegate;
            [d.alertWindowController displayError:error.localizedDescription code:PFCoreDataLoadError];
#endif
        }
    }];
    if (self.enableRemoteStorage) {
        [self loadCloudKitContainer];
    }
    //set to sort with newest on top
    self.sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO selector:@selector(compare:)];
    [self loadSavedData];
    [self deleteOverMaxItems];


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
        if (self.enableRemoteStorage) {
            [self storeRemote:pw];
        }
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
            if (self.enableRemoteStorage) {
                [self deleteRemote:p];
            }
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

-(void)synchronizeWithRemote {
    
}
-(void)receivedUpdatedData:(void (^)(BOOL))completionHandler {
    
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
    if (self.enableRemoteStorage) {
        [self deleteRemote:curr];
    }
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
    [self loadSavedData];
}
-(void)deleteAllRemoteObjects {
    __weak PasswordStorage *weakSelf = self;
    [self.cloudKitDatabase deleteRecordZoneWithID:self.cloudKitRecordZone.zoneID completionHandler:^(CKRecordZoneID * _Nullable zoneID, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CK ZON DEL %@",error.localizedDescription);
        }
        [weakSelf deleteAllEntities];
    }];
    
}
-(void)loadCloudKitContainer {

    self.cloudKitContainer = [CKContainer containerWithIdentifier:iCloudContainer];
    self.cloudKitDatabase = self.cloudKitContainer.privateCloudDatabase;
    self.cloudKitRecordZone = [[CKRecordZone alloc] initWithZoneName:iCloudContainerZone];
    [self.cloudKitDatabase saveRecordZone:self.cloudKitRecordZone completionHandler:^(CKRecordZone * _Nullable zone, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CK ZON CR %@",error.localizedDescription);
        }
    }];
    
}
-(void)enableRemoteStorage:(BOOL)enabled {
    self.enableRemoteStorage = enabled;
    if (enabled) {
        [self loadCloudKitContainer];
    } else {

    }
    
}
-(CKRecordID *)getRecordIDFor:(Passwords *)password {
    NSString *salt = [NSString stringWithFormat:@"%@%d%f",password.password,password.type,password.time.timeIntervalSince1970];
    return [[CKRecordID alloc] initWithRecordName:[salt sha1] zoneID:self.cloudKitRecordZone.zoneID];
}
-(void)deleteRemote:(Passwords *)password {
    CKRecordID *recordID = [self getRecordIDFor:password];
    [self.cloudKitDatabase deleteRecordWithID:recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CK DEL ERR %@",error.localizedDescription);
        }
    }];
}
-(void)storeRemote:(Passwords *)password {
    CKRecordID *recordID = [self getRecordIDFor:password];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Passwords" recordID:recordID];
    [record setObject:password.password forKey:@"password"];
    [record setObject:[NSNumber numberWithFloat:password.strength] forKey:@"strength"];
    [record setObject:password.time forKey:@"time"];
    [record setObject:[NSNumber numberWithInt:password.type] forKey:@"type"];
    [record setObject:[NSNumber numberWithInt:password.length] forKey:@"length"];
    
    [self.cloudKitDatabase saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CK SAVE ERR %@",error.localizedDescription);
        }
    }];
}

/**
 Called when max storage amount was changed
 */
-(void)changedMaxStorageAmount {
    [self loadSavedData];
    [self deleteOverMaxItems];
}



@end
