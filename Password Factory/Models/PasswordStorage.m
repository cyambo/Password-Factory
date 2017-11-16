//
//  PasswordStorage.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//



#import "PasswordStorage.h"
#import "constants.h"
@interface PasswordStorage ()
@property (nonatomic, strong) NSMutableArray *passwords;
@property (nonatomic, strong) NSMutableArray *sortedPasswords;
@property (nonatomic, strong) NSSortDescriptor *sort;
@property (nonatomic, strong) NSPersistentContainer *container;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end
@implementation PasswordStorage
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
    self.maximumPasswordsStored = 100;
    self.container = [[NSPersistentContainer alloc] initWithName:@"StoredPasswordModel"];
    [self.container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull storeDescription, NSError * _Nullable error) {
        self.container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        if(error) {
            NSLog(@"CORE DATA LOAD ERROR");
        }
    }];
    NSLog(@"%@",self.container.persistentStoreDescriptions.firstObject.URL);
    //set to sort with newest on top
    self.sort = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO selector:@selector(compare:)];
    [self loadSavedData];
    [self deleteOverMaxItems];
    return self;
}
-(void)storePassword:(NSString *)password strength:(float)strength type:(PFPasswordType)type {
    Passwords *pw = [[Passwords alloc] initWithContext:self.container.viewContext];
    pw.password = password;
    pw.strength = strength;
    pw.type = type;
    pw.time = [NSDate date];
    [self saveContext];
    [self loadSavedData];
    [self deleteOverMaxItems];
}
-(void)deleteOverMaxItems {
    if ([self count] > self.maximumPasswordsStored) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Passwords"];
        
        fetchRequest.fetchLimit = [self count] - self.maximumPasswordsStored;
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]];
        
        NSError *error = nil;
        NSArray *items = [self.container.viewContext executeFetchRequest:fetchRequest error:&error];
        if (error.localizedDescription) {
            NSLog(@"FETCH ERROR %@",error.localizedDescription);
        }
        for(Passwords *p in items) {
            [self.container.viewContext deleteObject:p];
        }
    }

}
-(void)saveContext {
    if (self.container.viewContext.hasChanges) {
        NSError *error = nil;
        [self.container.viewContext save:&error];
        if (error.localizedDescription) {
            NSLog(@"SAVE FAILED %@",error.localizedDescription);
        }
    }
}
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
        NSLog(@"FETCH FAILED %@",error.localizedDescription);
    }
}
-(NSUInteger)count {
    return self.fetchedResultsController.sections[0].numberOfObjects;
}
-(Passwords *)passwordAtIndex:(NSUInteger)index {
    NSUInteger indexArr[] = {0,index};
    NSIndexPath *p = [[NSIndexPath alloc] initWithIndexes:indexArr length:2];
    return [self.fetchedResultsController objectAtIndexPath:p];
}

-(void)setSortDescriptor:(NSSortDescriptor *)sortDescriptor {
    self.sort = sortDescriptor;
    [self loadSavedData];
}
-(void)deleteAllEntities {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Passwords"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    
    NSError *error = nil;
    [self.container.viewContext executeRequest:delete error:&error];
    if (error.localizedDescription) {
        NSLog(@"DELETE FAILED %@",error.localizedDescription);
    }
}
@end
