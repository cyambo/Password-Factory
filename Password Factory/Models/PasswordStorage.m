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
@property (nonatomic, strong) CKSubscription *recordSubscription;
@property (nonatomic, assign) BOOL hasUnsyncedChanges;

@end
@implementation PasswordStorage
#pragma  mark init
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
    self.hasUnsyncedChanges = YES;
    [self enableRemoteStorage:self.enableRemoteStorage];
    //set to sort with newest on top
    self.sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO selector:@selector(compare:)];
    [self loadSavedData];
    [self deleteOverMaxItems];


    return self;
}

#pragma mark Save / Load

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
#pragma mark Store
/**
 Stores the password in Core Data with the current date

 @param password Password to be stored
 @param strength strength of password
 @param type PFPasswordType of password
 */
-(void)storePassword:(NSString *)password strength:(float)strength type:(PFPasswordType)type {
    if (strength > 1.0) {
        NSLog(@"STRENGTH ERRRR");
    }
    [self storePassword:password strength:strength type:type time:[NSDate date] fromRemote:NO];
}

/**
 Stores the password in Core Data with the specified date
 
 @param password Password to be stored
 @param strength strength of password
 @param type PFPasswordType of password
 @param time time of creation
 */
-(void)storePassword:(NSString *)password strength:(float)strength type:(PFPasswordType)type time:(NSDate *)time fromRemote:(BOOL)fromRemote {
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
        pw.time = time;
        pw.passwordID = [self getIDFor:pw];
        pw.synced = NO;
        if (self.enableRemoteStorage && !fromRemote) {
            [self storeRemote:pw];
        }
        //save it
        [self saveContext];
        [self loadSavedData];
        [self deleteOverMaxItems];
    }
}
#pragma mark Fetch

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
 Gets a password by passwordID

 @param passwordID password ID string
 @return password found
 */
-(Passwords *)passwordWithID:(NSString *)passwordID {
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Passwords"];
    [req setPredicate:[NSPredicate predicateWithFormat:@"passwordID == %@",passwordID]];
    NSError *error = nil;
    NSArray *results = [self.container.viewContext executeFetchRequest:req error:&error];
    if (results.count) {
        return results[0];
    }
    return nil;
    
}
#pragma mark Delete

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
        //TODO: batch delete?
        for(Passwords *p in items) {
            @try {
                [self.container.viewContext deleteObject:p];
            }
            @catch (NSException *e) {
                NSLog(@"BATCH DELETE ERR %@",e);
            }
            if (self.enableRemoteStorage) {
                [self deleteRemote:p];
            }
        }
        [self saveContext];
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
    [self deletePassword:curr];
}


/**
 Deletes a password with a passwordID

 @param passwordID password ID
 */
-(void)deletePasswordWithID:(NSString *)passwordID {
    Passwords *password = [self passwordWithID:passwordID];
    if (password != nil) {
        [self deletePassword:password];
    }
}

/**
 Deletes a password item from CoreData

 @param password password to delete
 */
-(void)deletePassword:(Passwords *)password {
    [self.container.viewContext deleteObject:password];
    [self saveContext];
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


#pragma mark Misc

/**
 Changes the sort descriptor
 
 @param sortDescriptor to sort
 */
-(void)setSortDescriptor:(NSSortDescriptor *)sortDescriptor {
    self.sort = sortDescriptor;
    [self loadSavedData];
}

/**
 Called when max storage amount was changed
 */
-(void)changedMaxStorageAmount {
    [self loadSavedData];
    [self deleteOverMaxItems];
}


/**
 Enables CloudKit remote storage

 @param enabled enabled boolean
 */
-(void)enableRemoteStorage:(BOOL)enabled {
    self.enableRemoteStorage = enabled;
    if (enabled) {
        NSLog(@"ENABLING REMOTE STORAGE");
        __weak PasswordStorage *weakSelf = self;
        [self loadCloudKitContainer:^{
            [weakSelf loadSubscription];
            [weakSelf fetchRemoteChanges];
            [weakSelf synchronizeWithRemote];
        }];
        
    } else {
        //TODO: disable properly
    }
}

/**
 Returns the unique id for a Password item

 @param password password to getr unique id
 @return unique id
 */
-(NSString *)getIDFor:(Passwords *)password {
    NSString *salt = [NSString stringWithFormat:@"%@%d%lf",password.password,password.type,password.time.timeIntervalSinceReferenceDate];
    return [salt sha1];
}

#pragma mark CloudKit

/**
 Loads the CloudKit container

 @param completionHandler called on completion
 */
-(void)loadCloudKitContainer:(void (^)(void))completionHandler {

    self.cloudKitContainer = [CKContainer containerWithIdentifier:iCloudContainer];
    self.cloudKitDatabase = self.cloudKitContainer.privateCloudDatabase;
    self.cloudKitRecordZone = [[CKRecordZone alloc] initWithZoneName:iCloudContainerZone];
    [self.cloudKitDatabase saveRecordZone:self.cloudKitRecordZone completionHandler:^(CKRecordZone * _Nullable zone, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CK ZON CR %@",error.localizedDescription);
        } else {
            NSLog(@"LOADED CK CONTAINER ZONE");
            if (completionHandler != nil) {
               completionHandler();
            }
            
        }
    }];
}

/**
 Creates, or loads the subscriptions so we can get updates in real time
 */
-(void)loadSubscription {
    if (self.recordSubscription == nil) {
        __weak PasswordStorage* weakSelf = self;

        [self.cloudKitDatabase fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> * _Nullable subscriptions, NSError * _Nullable error) {
            if (error) {
                NSLog(@"CK SUB FA %@",error.localizedDescription);
            } else {
                if (subscriptions != nil && subscriptions.count) {
                    for(int i = 0; i < subscriptions.count; i++) {
                        CKSubscription *sub = subscriptions[i];
                        if ([sub.notificationInfo.alertLocalizationKey isEqualToString:@"password_remote_update"]) {
                            NSLog(@"FOUND RECORD SUB");
                            weakSelf.recordSubscription = sub;
                        }
                    }
                }
            }
            if (weakSelf.recordSubscription == nil) {
                [weakSelf createRecordSubscription];
            }

        }];
    }
}


/**
 Creates the record subscription
 */
-(void)createRecordSubscription {

    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    self.recordSubscription = [[CKQuerySubscription alloc] initWithRecordType:@"Passwords" predicate: predicate options:CKQuerySubscriptionOptionsFiresOnRecordCreation | CKQuerySubscriptionOptionsFiresOnRecordDeletion ];
    //
    CKNotificationInfo *info = [[CKNotificationInfo alloc] init];
    info.alertLocalizationKey = @"password_remote_update";
    //                        info.
    info.desiredKeys = @[@"password",@"time",@"type",@"strength"];
    self.recordSubscription.notificationInfo = info;
    
    
    [self.cloudKitDatabase saveSubscription:self.recordSubscription completionHandler:^(CKSubscription * _Nullable subscription, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CK SUB CR %@",error.localizedDescription);
        } else {
            NSLog(@"RECORD SUB CREATED");
        }
        //TODO: save id in defaults
    }];
}


/**
 Syncronizes any unsynced passwords to remote
 */
-(void)synchronizeWithRemote {
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Passwords"];
    [req setPredicate:[NSPredicate predicateWithFormat:@"synced == 0"]];
    NSError *error = nil;
    NSArray *results = [self.container.viewContext executeFetchRequest:req error:&error];
    for(Passwords *p in results) {
        [self storeRemote:p];
    }
    self.hasUnsyncedChanges = NO;
}

/**
 Fetches remote changes since last load
 */
-(void)fetchRemoteChanges {
    NSLog(@"FETCHING REMOTE CHANGES");
    //loading the change token from defaults
    CKFetchRecordZoneChangesOptions *opt = [[CKFetchRecordZoneChangesOptions alloc] init];
    NSData *token = [self.d objectForKey:@"cloudKitChangeToken"];
    if (token) {
        //if it is found, set the token
        CKServerChangeToken *t = [NSKeyedUnarchiver unarchiveObjectWithData:token];
        if (t != nil){
            opt.previousServerChangeToken = t;
        }
    }
    
    //setup the operation
    CKFetchRecordZoneChangesOperation *op = [[CKFetchRecordZoneChangesOperation alloc] initWithRecordZoneIDs:@[self.cloudKitRecordZone.zoneID] optionsByRecordZoneID:@{self.cloudKitRecordZone.zoneID : opt}];
    op.fetchAllChanges = YES;
    
    __weak PasswordStorage* weakSelf = self;
    
    //block for changed records either insert or modify a record
    [op setRecordChangedBlock:^(CKRecord * _Nonnull record) {
        
        Passwords *search;
        if ((search = [weakSelf passwordWithID:record.recordID.recordName])) {
            NSLog(@"FETCH MODIFY %@",search.password);
        } else {
            Passwords *pw = [[Passwords alloc] initWithContext:self.container.viewContext];
            pw.password = [record objectForKey:@"password"];
            pw.strength = [(NSNumber *)[record objectForKey:@"strength"] floatValue];
            pw.type = [(NSNumber *)[record objectForKey:@"type"] integerValue];
            pw.length = [(NSNumber *)[record objectForKey:@"length"] integerValue];
            pw.time = [record objectForKey:@"time"];
            pw.passwordID = record.recordID.recordName;
            pw.synced = YES;
            NSLog(@"FETCH ADD %@",pw.password);
        }
    }];
    //block for deleted records, will delete local record
    [op setRecordWithIDWasDeletedBlock:^(CKRecordID * _Nonnull recordID, NSString * _Nonnull recordType) {
        [weakSelf deletePasswordWithID:recordID.recordName];
        NSLog(@"FETCH DELETE ID %@",recordID.recordName);
    }];
    
    //token updated, so save
    [op setRecordZoneChangeTokensUpdatedBlock:^(CKRecordZoneID * _Nonnull recordZoneID, CKServerChangeToken * _Nullable serverChangeToken, NSData * _Nullable clientChangeTokenData) {
        [self saveChangeToken:serverChangeToken];
        NSLog(@"FETCH TOKEN UPDATE");
    }];
    
    //operation complete, so save everything
    [op setRecordZoneFetchCompletionBlock:^(CKRecordZoneID * _Nonnull recordZoneID, CKServerChangeToken * _Nullable serverChangeToken, NSData * _Nullable clientChangeTokenData, BOOL moreComing, NSError * _Nullable recordZoneError) {
        if (serverChangeToken != nil && !moreComing) {
            NSLog(@"FETCH UPDATE COMPLETE"); //save token here
            [self saveChangeToken:serverChangeToken];
            [weakSelf saveContext];
            [weakSelf loadSavedData];
            [weakSelf deleteOverMaxItems];
        }
    }];
    [self.cloudKitDatabase addOperation:op];
}

/**
 Saves the server change token in defaults

 @param token server token to save
 */
-(void)saveChangeToken:(CKServerChangeToken *)token {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:token];
    [self.d setObject:data forKey:@"cloudKitChangeToken"];
}


/**
 Retrieves all the remotely stored record ids

 @param completionHandler called with all found record ids
 */
-(void)fetchAllRemoteRecordIDs:(void (^)(NSArray*))completionHandler {
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Passwords" predicate:predicate];
    
    [self.cloudKitDatabase performQuery:query inZoneWithID:self.cloudKitRecordZone.zoneID completionHandler:^(NSArray *results, NSError *error) {
        NSMutableArray *ids = [[NSMutableArray alloc] init];
        for (CKRecord *record in results) {
            [ids addObject:record.recordID];
        }
        completionHandler(ids);
    }];

}
/**
 Deletes all the passwords in cloudkit
 */
-(void)deleteAllRemoteObjects {

    __weak PasswordStorage *weakSelf = self;

    [self fetchAllRemoteRecordIDs:^(NSArray *recordIds) {
        if (recordIds.count) {
            CKModifyRecordsOperation *op = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:recordIds];
            op.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> * _Nullable savedRecords, NSArray<CKRecordID *> * _Nullable deletedRecordIDs, NSError * _Nullable operationError) {
                if (operationError) {
                    NSLog(@"DELETE BATCH FAIL %@",operationError.localizedDescription);
                } else {
                    NSLog(@"DELETED %d REMOTE OBJECTS",(int)recordIds.count);
                    [weakSelf deleteSubscriptions];
                    if (weakSelf.enableRemoteStorage) {
                        NSLog(@"DELETING LOCAL OBJECTS");
                        [weakSelf deleteAllEntities];
                        [weakSelf loadCloudKitContainer:nil];
                    }
                }
            };
            [self.cloudKitDatabase addOperation:op];
        }
    }];

}


/**
 deletes the record subscriptions
 */
-(void)deleteSubscriptions {

    if (self.recordSubscription != nil) {
        CKModifySubscriptionsOperation *modifySubOp = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:nil subscriptionIDsToDelete:@[self.recordSubscription.subscriptionID]];
        
        modifySubOp.modifySubscriptionsCompletionBlock = ^(NSArray<CKSubscription *> * _Nullable savedSubscriptions, NSArray<NSString *> * _Nullable deletedSubscriptionIDs, NSError * _Nullable operationError) {
            if (operationError) {
                NSLog(@"SUB DELETE ERR %@",operationError.localizedDescription);
            } else {
                NSLog(@"DELETED SUBSCRIPTIONS");
            }
        };
        [self.cloudKitDatabase addOperation:modifySubOp];
        self.recordSubscription = nil;
    }
}
/**
 Returns the CKRecordID for a password

 @param password password to get id
 @return CKRecordID
 */
-(CKRecordID *)getRecordIDFor:(Passwords *)password {
    return [[CKRecordID alloc] initWithRecordName:[self getIDFor:password] zoneID:self.cloudKitRecordZone.zoneID];
}

/**
 Deletes a password in cloudkit

 @param password password to delete
 */
-(void)deleteRemote:(Passwords *)password {
    CKRecordID *recordID = [self getRecordIDFor:password];
    [self.cloudKitDatabase deleteRecordWithID:recordID completionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CK DEL ERR %@",error.localizedDescription);
        } else {
            NSLog(@"DELETE REMOTE %@",recordID.recordName);
        }
    }];
}


/**
 Retrieves a remote object from a recordID

 @param record recordID to fetch
 @param completion completion with recordID
 */
-(void)getRemote:(CKRecordID *)record completionHandler:(void (^)(CKRecord *))completion {
    [self.cloudKitDatabase fetchRecordWithID:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if(error) {
            NSLog(@"CK FR ERR %@" , error.localizedDescription);
            completion(nil);
        } else {
            NSLog(@"GET REMOTE RECORD %@",record.recordID.recordName);
            completion(record);
        }
    }];
}

/**
 Stores a password in CloudKit

 @param password password to store
 */
-(void)storeRemote:(Passwords *)password {
    CKRecordID *recordID = [self getRecordIDFor:password];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Passwords" recordID:recordID];
    [record setObject:password.password forKey:@"password"];
    [record setObject:[NSNumber numberWithFloat:password.strength] forKey:@"strength"];
    [record setObject:password.time forKey:@"time"];
    [record setObject:[NSNumber numberWithInt:password.type] forKey:@"type"];
    [record setObject:[NSNumber numberWithInt:password.length] forKey:@"length"];
    if (record != nil && !password.synced) {
        __weak PasswordStorage *weakSelf = self;
        [self.cloudKitDatabase saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            if (error) {
                NSLog(@"CK SAVE ERR %@",error.localizedDescription);
                //if there is a failure, do nothing, so we can try later
                if (error.code == CKErrorServerRecordChanged) { // item already in db so mark it at synced
                    NSLog(@"ALREADY SYNCED %@",password.password);
                    password.synced = YES;
                    [weakSelf saveContext];
                } else {
                    weakSelf.hasUnsyncedChanges = YES;
                }
            } else {
                NSLog(@"REMOTE STORED %@",password.password);
                //mark the password as synced, and save it
                password.synced = YES;
                if (password.inserted) {
                    [weakSelf saveContext];
                }
                
                if (weakSelf.hasUnsyncedChanges) {
                    [weakSelf synchronizeWithRemote];
                }
            }
            
        }];
    }
}


/**
 Data was received from a push notification

 @param notification CKNotification from push
 @param completionHandler called when complete, and sets success
 */
-(void)receivedUpdatedData:(CKNotification *)notification complete:(void (^)(BOOL))completionHandler {
    if ([notification isKindOfClass:[CKQueryNotification class]]) {
        CKQueryNotification *queryNotification = (CKQueryNotification *)notification;
        if (queryNotification.queryNotificationReason == CKQueryNotificationReasonRecordCreated) {
            //checking to see if all data was received
            if (queryNotification.recordFields.count == 4) {
                
                NSDictionary *r = queryNotification.recordFields;
                NSLog(@"NOTIFY ADD %@",r[@"password"]);
                NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:[(NSNumber *)r[@"time"] doubleValue]];
                [self storePassword:r[@"password"] strength:[(NSNumber *)r[@"strength"] floatValue] type:[(NSNumber *)r[@"type"] integerValue]  time:date fromRemote:YES];
                completionHandler(YES);
            }
        } else if (queryNotification.queryNotificationReason == CKQueryNotificationReasonRecordDeleted) {
            if (queryNotification.recordID.recordName != nil) {
                NSLog(@"NOTIFY DELETE %@",queryNotification.recordID.recordName);
                [self deletePasswordWithID:queryNotification.recordID.recordName];
                completionHandler(YES);
            }
        }
    }
    completionHandler(NO);
}


@end
