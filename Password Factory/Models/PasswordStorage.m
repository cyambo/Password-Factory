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
@interface PasswordStorage () <DefaultsManagerDelegate>
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
#pragma mark Fetch Info

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
        [self.d observeDefaults:self keys:@[@"cloudKitZoneCreated"]];
        NSLog(@"ENABLING REMOTE STORAGE");
        __weak PasswordStorage *weakSelf = self;
        [self loadCloudKitContainer:^{
            [weakSelf loadSubscription];
            [weakSelf fetchRemoteChanges];
            [weakSelf synchronizeWithRemote];
        }];
        
    } else {
        [self.d removeDefaultsObservers:self keys:@[@"cloudKitZoneCreated"]];
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
    __weak PasswordStorage *weakSelf = self;
    [self.cloudKitDatabase saveRecordZone:self.cloudKitRecordZone completionHandler:^(CKRecordZone * _Nullable zone, NSError * _Nullable error) {
        if (error) {
            NSLog(@"CK ZON CR %@",error.localizedDescription);
        } else {
            NSLog(@"LOADED CK CONTAINER ZONE");
            //checking to see when the zone was created and loaded to determine what to sync
            float zoneTime = [weakSelf.d floatForKey:@"cloudKitZoneCreated"];
            float zoneLoaded = [weakSelf.d floatForKey:@"cloudKitZoneLoaded"];
            //if both are zero, then it is a new zone, so set to now
            if (zoneTime == 0 && zoneLoaded == 0) {
                zoneTime = [NSDate date].timeIntervalSinceReferenceDate;
                zoneLoaded = zoneTime;
            //if zone loaded is zero and zone time is set that means we never synced
            //and load the zone
            } else if (zoneTime > zoneLoaded) {
                //synchronize with remote
                [weakSelf synchronizeWithRemote];
                //set zone loaded to now
                zoneLoaded = [NSDate date].timeIntervalSinceReferenceDate;
                
                NSLog(@"NEED TO SYNC");
            
            } else if (zoneTime == 0 && zoneLoaded != 0) {
                NSLog(@"ZONE TIME ZERO"); //shouldn't get here, but if we do set zoneTime to zoneLoaded and sync
                zoneTime = zoneLoaded;
                [weakSelf synchronizeWithRemote];
            }
            //set current creation date
            
            [weakSelf.d setFloat:zoneLoaded forKey:@"cloudKitZoneLoaded"];
            [weakSelf.d setFloat:zoneTime forKey:@"cloudKitZoneCreated"];
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
-(void)synchronizeWithRemote {
    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Passwords"];
    [req setPredicate:[NSPredicate predicateWithFormat:@"synced == 0"]];
    NSError *error = nil;
    NSArray *results = [self.container.viewContext executeFetchRequest:req error:&error];
    for(Passwords *p in results) {
        [self storeRemote:p];
    }

}
/**
 Fetches remote changes since last load
 */
-(void)fetchRemoteChanges {
    NSLog(@"FETCHING REMOTE CHANGES");
    CKFetchRecordZoneChangesOptions *opt = [[CKFetchRecordZoneChangesOptions alloc] init];
    NSData *token = [self.d objectForKey:@"cloudKitChangeToken"];
    if (token) {
        CKServerChangeToken *t = [NSKeyedUnarchiver unarchiveObjectWithData:token];
        if (t != nil){
            opt.previousServerChangeToken = t;
        }
    }
    CKFetchRecordZoneChangesOperation *op = [[CKFetchRecordZoneChangesOperation alloc] initWithRecordZoneIDs:@[self.cloudKitRecordZone.zoneID] optionsByRecordZoneID:@{self.cloudKitRecordZone.zoneID : opt}];
    op.fetchAllChanges = YES;
    
    __weak PasswordStorage* weakSelf = self;
    
    [op setRecordChangedBlock:^(CKRecord * _Nonnull record) {
        
        Passwords *search;
        if ((search = [weakSelf passwordWithID:record.recordID.recordName])) {
            NSLog(@"FETCH MODIFY %@",search.password);
//            [weakSelf deletePassword:search];
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
    [op setRecordWithIDWasDeletedBlock:^(CKRecordID * _Nonnull recordID, NSString * _Nonnull recordType) {
        [weakSelf deletePasswordWithID:recordID.recordName];
        NSLog(@"FETCH DELETE ID %@",recordID.recordName);
    }];
    [op setRecordZoneChangeTokensUpdatedBlock:^(CKRecordZoneID * _Nonnull recordZoneID, CKServerChangeToken * _Nullable serverChangeToken, NSData * _Nullable clientChangeTokenData) {
        [self saveChangeToken:serverChangeToken];
        NSLog(@"FETCH TOKEN UPDATE");
    }];
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
 Deletes all the passwords in cloudkit - does this by deleting the zone
 */
-(void)deleteAllRemoteObjects {

    __weak PasswordStorage *weakSelf = self;
    if (self.cloudKitRecordZone != nil) {
        CKModifyRecordZonesOperation *modifyZoneOp = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:nil recordZoneIDsToDelete:@[self.cloudKitRecordZone.zoneID]];
        modifyZoneOp.modifyRecordZonesCompletionBlock = ^(NSArray<CKRecordZone *> * _Nullable savedRecordZones, NSArray<CKRecordZoneID *> * _Nullable deletedRecordZoneIDs, NSError * _Nullable operationError) {
            if (operationError) {
                NSLog(@"CK ZON DEL %@",operationError.localizedDescription);
            } else {
                NSLog(@"DELETE ALL REMOTE OBJECTS");
                [weakSelf deleteSubscriptions];
                [self.d setObject:nil forKey:@"cloudKitChangeToken"];
                [self.d setFloat:0.0 forKey:@"cloudKitZoneCreated"];
                [self.d setFloat:0.0 forKey:@"cloudKitZoneLoaded"];
                if (weakSelf.enableRemoteStorage) {
                    NSLog(@"DELETING LOCAL OBJECTS");
                    [weakSelf deleteAllEntities];
                    [weakSelf loadCloudKitContainer:nil];
                }
                
            }
        };
        [self.cloudKitDatabase addOperation:modifyZoneOp];
        
        self.cloudKitRecordZone = nil;
        self.cloudKitDatabase = nil;
        self.cloudKitContainer = nil;
    }
}
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
    if (record != nil) {
        __weak PasswordStorage *weakSelf = self;
        [self.cloudKitDatabase saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            if (error) {
                NSLog(@"CK SAVE ERR %@",error.localizedDescription);
                //if there is a failure, do nothing, so we can try later
                if (error.code == CKErrorServerRecordChanged) { // item already in db so mark it at synced
                    password.synced = YES;
                    [weakSelf saveContext];
                }
            } else {
                NSLog(@"REMOTE STORED %@",password.password);
                //mark the password as synced, and save it
                password.synced = YES;
                [weakSelf saveContext];
                [weakSelf synchronizeWithRemote];
            }
            
        }];
    }
}

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
- (void)observeValue:(NSString * _Nullable)keyPath change:(NSDictionary * _Nullable)change {
    //checking for an updated zone creation time - that means iCloud data was erased
    if ([keyPath isEqualToString:@"cloudKitZoneCreated"]) {
        //load our create time
        float currentZoneTime = [self.d floatForKey:@"cloudKitZoneCreated"];
        if (currentZoneTime != 0.0) {
            //get the changed time
            float changedZonedTime = [(NSNumber *)change[@"new"] floatValue];
            //and if it is latger than our time, delete and reload everything
            if (changedZonedTime > currentZoneTime) {
                NSLog(@"REMOTE DELETE ALL");
                [self deleteAllEntities];
                [self loadCloudKitContainer:nil];
            }
        }
    }
}

@end
