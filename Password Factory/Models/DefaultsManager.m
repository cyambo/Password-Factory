//
//  DefaultsManager.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/19/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//
#include <mach/mach.h>
#include <mach/mach_time.h>
#import "DefaultsManager.h"
#import "constants.h"
#import "PasswordFactoryConstants.h"
@import SBObjectiveCWrapper;
static mach_timebase_info_data_t _sTimebaseInfo;
static BOOL _useSharedDataSource = NO;
uint64_t  _newTime, _previousTime, _elapsed, _elapsedNano, _threshold;
NSString  *_previousKeyPath;

@interface DefaultsManager ()
@property (nonatomic, strong) NSUserDefaults *sharedDefaults;
@property (nonatomic, strong) NSUserDefaults *standardDefaults;
@property (nonatomic, strong) NSUbiquitousKeyValueStore *keyStore;
@property (nonatomic, strong) NSMutableDictionary *standardDefaultsCache;
@property (nonatomic, strong) NSMutableDictionary *sharedDefaultsCache;
@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, strong) NSMutableDictionary *kvos;
@property (nonatomic, assign) bool stopObservers;
@property (nonatomic, strong) NSMutableArray *disabledSyncKeys;
@property (nonatomic, assign) BOOL useRemoteStorage;
@end
@implementation DefaultsManager

static DefaultsManager *dm = nil;

/**
 Singleton Get method

 @return DefaultsManager instance
 */
+(instancetype) get {
    if (!dm) {
        static dispatch_once_t once = 0;
        dispatch_once(&once, ^ {
            dm = [[DefaultsManager alloc] init];
        });
    }
    return dm;
}

/**
 Initializes DefaultsManager

 @return DefaultsManager object
 */
-(instancetype)init {
    self = [super init];
    [self setupCache];
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SharedDefaultsAppGroup];
    self.standardDefaults = [NSUserDefaults standardUserDefaults];
    [self loadDefaultsPlist];
    BOOL loadedPlist = NO;
    //check to see if it was initialized, if it wasn't this is the first load, so initialize from plist
    if (![self.standardDefaults boolForKey:@"initializedDefaults"]) {
        [self getPrefsFromPlist:true];
        [self.standardDefaults setBool:YES forKey:@"initializedDefaults"];
        loadedPlist = YES;
    }
    self.observers = [[NSMutableDictionary alloc] init];
    self.kvos = [[NSMutableDictionary alloc] init];
    self.stopObservers = false;
    
    [self addObservers];
    [self disableRemoteSyncForKeys:[PasswordFactoryConstants get].disabledSyncKeys];
    [self enableRemoteStore:[self.standardDefaults boolForKey:@"enableRemoteStore"]];
    if (!loadedPlist) {
        [self getPrefsFromPlist:false];
    }
    [self syncToSharedDefaults];
    return self;
}

/**
 Enables the iCloud remote KVO store

 @param enable enable bopol
 */
-(void)enableRemoteStore:(BOOL)enable {
    self.useRemoteStorage = enable;
    if (enable) {
        //initialize the store

        self.keyStore = [NSUbiquitousKeyValueStore defaultStore];

        //set the change observer
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(remoteStoreDidChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.keyStore];
        [self.keyStore synchronize];
        [self getPrefsFromPlist:false];
    } else {
        //erase the key store and disable the change observer
        if (self.keyStore != nil) {
            [NSNotificationCenter.defaultCenter removeObserver:self name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:self.keyStore];
            self.keyStore = nil;
        }
    }
}

/**
 Disables sync to remote iCloud KVO for certain keys

 @param keys array of keys to not sync
 */
-(void)disableRemoteSyncForKeys:(NSArray *)keys {
    if (self.disabledSyncKeys == nil) {
        self.disabledSyncKeys = [[NSMutableArray alloc] init];
    }
    for (NSString *k in keys) {
        if (![self.disabledSyncKeys containsObject:k]) {
            [self.disabledSyncKeys addObject:k];
        }
    }
}

/**
 Syncs our plist to the sharedDefaults manager for use in the today extension
 */
-(void)syncToSharedDefaults {
    //don't sync back if we are using the shared data source
    if (!DefaultsManager.useSharedDataSource) {
        [self loadDefaultsPlist];
        NSUserDefaults *sharedDefaults = self.sharedDefaults;
        NSUserDefaults *d = self.standardDefaults;
        for (NSString *key in self.prefsPlist) {
            NSString *k = [key stringByAppendingString:@"Shared"]; //Appending shared to shared defaults because KVO will cause the observer to be called
            id obj = [d objectForKey:key];
            //syncing to shared defaults
            if ([self canSyncKey:k]) {
                if(![self compareDefaultsObject:[sharedDefaults objectForKey:k] two:obj]) {
                    [sharedDefaults setObject:[d objectForKey:key] forKey:k];
                }
            }
        }
    }
}

/**
 Checks to see if key should be synced to remote key store

 @param key key to check
 @return YES if can sync
 */
-(BOOL)canSyncKey:(NSString *)key {
    //if it isn't in the prefs plist, then don't sync
    if(self.prefsPlist[key] == nil) {
        return NO;
    }
    //if it is in the disabled sync keys array, do not sync
    if (self.disabledSyncKeys != nil && [self.disabledSyncKeys containsObject:key]) {
        return NO;
    }
    //othwise, sync
    return YES;
}
/**
 Gets the shared defaults for the app

 @return shared defaults
 */
+(NSUserDefaults *)sharedDefaults {
    NSUserDefaults *s = [DefaultsManager get].sharedDefaults;
    return s;
}

/**
 Gets the standardUserDefaults

 @return standard defaults
 */
+(NSUserDefaults *)standardDefaults {
    NSUserDefaults *s = [DefaultsManager get].standardDefaults;
    return s;
}

/**
 Restores defaults to base
 */
+(void)restoreUserDefaults {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[DefaultsManager standardDefaults] removePersistentDomainForName:appDomain];
    [[DefaultsManager sharedDefaults] removePersistentDomainForName:SharedDefaultsAppGroup];
    [DefaultsManager resetRemoteDefaults:nil];
    [[DefaultsManager get] getPrefsFromPlist:true];
}


/**
 Resets all remote iCloud KVO defaults

 @param overrideValues overrides what the value will normally be with this
 */
+(void)resetRemoteDefaults:(NSDictionary *)overrideValues {
    NSUbiquitousKeyValueStore *store;
    if ([DefaultsManager get].keyStore) {
        store = [DefaultsManager get].keyStore;
    } else {
        store = [NSUbiquitousKeyValueStore defaultStore];
    }
    if (store != nil) {
        [[DefaultsManager get] loadDefaultsPlist];
        NSDictionary *prefs = [DefaultsManager get].prefsPlist;
        //resetting iCloudKVS to default
        for (NSString *key in prefs) {
            id currVal = [prefs objectForKey:key];
            if (overrideValues[key] != nil) {
                currVal = overrideValues[key];
            }
            [store setObject:currVal forKey:key];
        }
        //checking to see if there were any added keys that are not in prefs, if so, delete them
        NSDictionary *kvs = [store dictionaryRepresentation];
        for (NSString *key in [kvs allKeys]) {
            if (prefs[key] == nil && overrideValues[key] == nil) {
                SBLogDebug(@"DELETED EXTRANEOUS KEY %@",key);
                [store removeObjectForKey:key];
            } else if (overrideValues[key] != nil) {
                [store setObject:overrideValues[key] forKey:key];
            }
        }
    }
}
/**
 Sets all dialogs to be shown
 */
-(void)resetDialogs {
    [self loadDefaultsPlist];
    //taking plist and finding the dialogs and resetting them to not hide
    for (NSString *k in self.prefsPlist) {
        //check to see if it has Warning as a suffix which all dialogs have
        if ([k hasSuffix:@"Warning"]) {
            [self setBool:NO forKey:k];
        }
    }
}


/**
 Gets shared or standard defaults based on useShared

 @return defaults
 */
- (NSUserDefaults *)getDefaults {
    if(DefaultsManager.useSharedDataSource) {
        return self.sharedDefaults;
    } else {
        return self.standardDefaults;
    }
}

/**
 Object for key on defaults, will return cached item if defaults is not working

 @param key key to get
 @return object from defaults
 */
-(id)objectForKey:(NSString *)key {
    id object;
    id cached;
    if(DefaultsManager.useSharedDataSource) {
        key = [key stringByAppendingString:@"Shared"];
        object = [self.sharedDefaults objectForKey:key];
        cached = [self.sharedDefaultsCache objectForKey:key];
    } else {
        object = [self.standardDefaults objectForKey:key];
        cached = [self.standardDefaultsCache objectForKey:key];
    }
    if (object == nil){
        SBLogInfo(@"FAILED DEFAULTS %@",key);
        return cached;
    }
    return object;
}
/**
 stringForKey on defaults

 @param key key to get
 @return String from defaults
 */
- (NSString *)stringForKey:(NSString *)key {
    NSString *ret = (NSString *)[self objectForKey:key];
    if (ret == nil) {
        return @"";
    }
    return ret;
}
/**
 integerForKey on defaults
 
 @param key key to get
 @return integer from defaults
 */
- (NSInteger)integerForKey:(NSString *)key {
    id ret = [self objectForKey:key];
    if (ret == nil) {
        return 0;
    }
    return [ret integerValue];
}

/**
 boolForKey on defaults
 
 @param key key to get
 @return bool from defaults
 */
- (BOOL)boolForKey:(NSString *)key {
    id ret = [self objectForKey:key];
    if (ret == nil) {
        return NO;
    }
    return [ret boolValue];
}

/**
 floatForKey on defaults

 @param key key to get
 @return float from defaults
 */
- (float)floatForKey:(NSString *)key {
    id ret = [self objectForKey:key];
    if (ret == nil) {
        return 0.0;
    }
    return [ret floatValue];
}

/**
 Sets object in defaults, and the observer handles the rest

 @param object object to set
 @param key defaults key
 */
-(void)setObject:(id)object forKey:(NSString *)key {
    if (object == nil) {
        return;
    }
    //set the defaults
    [self.standardDefaults setObject:object forKey:key];
    //if we are not in kvos, then there is no observer, so call store
    //object directly
    if (self.kvos[key] == nil) {
        [self storeObject:object forKey:key];
    }
}

/**
 Stores object in cache, shared, and remote store

 @param object object to store
 @param keyPath key of object
 */
-(void)storeObject:(id)object forKey:(NSString *)keyPath {
    [self.standardDefaultsCache setObject:object forKey:keyPath];
    if ([self canSyncKey:keyPath]) {
        if (self.useRemoteStorage) {
            if (![self boolForKey:@"activeControl"]) {
                if (![self compareDefaultsObject:[self.keyStore objectForKey:keyPath] two:object]) {
                    [self.keyStore setObject:object forKey:keyPath];
                }
            }
        }
        //don't store back if we are using shared
        if (!DefaultsManager.useSharedDataSource) {
            NSString *sharedKey = [keyPath stringByAppendingString:@"Shared"];
            if (![self compareDefaultsObject:[self.sharedDefaults objectForKey:sharedKey] two:object]) {
                [self.sharedDefaults setObject:object forKey:sharedKey];
                [self.sharedDefaultsCache setObject:object forKey:sharedKey];
            }
        }

    }
}
/**
 Sets bool in defaults, shared defaults and cache

 @param object bool to set
 @param key defaults key
 */
-(void)setBool:(BOOL)object forKey:(NSString *)key {
    [self setObject:@(object) forKey:key];
}

/**
 Sets integer in defaults, shared defaults and cache

 @param object integer to set
 @param key defaults key
 */
-(void)setInteger:(NSInteger)object forKey:(NSString *)key {
    [self setObject:@(object) forKey:key];
}

/**
 Sets float in defaults, shared defaults and cache

 @param object float to set
 @param key defaults key
 */
-(void)setFloat:(float)object forKey:(NSString *)key {
    [self setObject:@(object) forKey:key];
}

/**
 Loads our defaults.plist into a dictionary
 */
-(void)loadDefaultsPlist {
    if (self.prefsPlist == nil) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
        self.prefsPlist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
}
/**
 Takes our defaults plist dictionary and merges it with standardUserDefaults so that our prefs are always set
 */
- (void)getPrefsFromPlist:(BOOL)initialize {
    [self loadDefaultsPlist];
    NSUserDefaults *d = self.standardDefaults;
    NSUbiquitousKeyValueStore *store = self.keyStore;
    self.stopObservers = true;
    //taking plist and filling in defaults if none set
    BOOL currentRemoteStore = self.useRemoteStorage;
    if (!initialize) {
        self.useRemoteStorage = NO;
    }
    for (NSString *k in self.prefsPlist) {
        id defaultsObject = [d objectForKey:k];
        id storeObject = [store objectForKey:k];
        id plistObject = [self.prefsPlist objectForKey:k];
        //if this is an initialization, just set directly from plist
        if (initialize) {
            [self setObject:plistObject forKey:k];
        //if the store has it and we don't set from the store
        } else if (currentRemoteStore && [self canSyncKey:k]) {
            //if defaults is nil and store isn't set from store
            if (defaultsObject == nil && storeObject != nil) {
                [self setObject:storeObject forKey:k];
            //if both don't have it, set from plist
            } else if (defaultsObject == nil && storeObject == nil) {
                [self setObject:plistObject forKey:k];
            //if there is no stored object set from plist
            } else if (storeObject == nil) {
                [self setObject:plistObject forKey:k];
            //if they are different, pull from stored
            } else if (![self compareDefaultsObject:storeObject two:defaultsObject]) {
                [self setObject:storeObject forKey:k];
            //if they are the same, and do not equal the plist item, do nothing
            } else if ([self compareDefaultsObject:storeObject two:defaultsObject] && storeObject != plistObject){
                //do nothing
            //otherwise set from plist
            } else {
                [self setObject:plistObject forKey:k];
            }
        } else {
            if(defaultsObject == nil) {
                [self setObject:plistObject forKey:k];
            }
        }

    }
    [self.standardDefaults synchronize];
    [self.sharedDefaults synchronize];
    self.useRemoteStorage = currentRemoteStore;
    self.stopObservers = false;
}

/**
 Called when an item on the remote key store has changed

 @param notification remote notification
 */
-(void)remoteStoreDidChange:(NSNotification *)notification {
    SBLogDebug(@"REMOTE CHANGES");
    if (notification.userInfo && notification.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey]) {
        BOOL currentRemoteStore = self.useRemoteStorage;
        //don't re-sync changes back to iCloud
        self.useRemoteStorage = false;
        //go through the notification
        for (NSString *item in notification.userInfo[NSUbiquitousKeyValueStoreChangedKeysKey]) {
            
            //only sync items that are enabled
            if ([self canSyncKey:item]) {
                SBLogDebug(@"REMOTE ITEM CHANGE %@",item);
                //get the new value
                id object = [self.keyStore objectForKey:item];
                //do not set nil object
                if (object != nil) {
                    //store it
                    [self setObject:object forKey:item];
                }
            }
        }
        //reenable remote store
        self.useRemoteStorage = currentRemoteStore;
    }
}

/**
 Adds observers for every key in defaults.plist
 */
-(void)addObservers {
    NSUserDefaults *d = self.standardDefaults;
    for (NSString *k in self.prefsPlist) {
        if (self.kvos[k] == nil) {
            [d addObserver:self forKeyPath:k options:NSKeyValueObservingOptionNew context:NULL];
            self.kvos[k] = @YES;
        }
    }
}

/**
 Sets up the defaults cache which is used when a macOS bug causes defaults to be nil
 */
-(void)setupCache {

    self.standardDefaultsCache = [[NSMutableDictionary alloc] init];
    self.sharedDefaultsCache = [[NSMutableDictionary alloc] init];
}

/**
 Called when an object has changed

 @param keyPath key of the changed object
 @param object object that changed
 @param change change description
 @param context context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    //don't do anything if we are a duplicate event
    if (![self timeThresholdForKeyPathExceeded:keyPath]) {
        return;
    }
    //don't do anything if the change is null
    if (change[@"new"] == [NSNull null]) {
        return;
    }
    //check to see if we have any observers
    if (!self.stopObservers && self.observers[keyPath]) {
        for(id o in self.observers[keyPath]) {
            //if the item conforms to the protocol, call it
            if ([o conformsToProtocol:@protocol(DefaultsManagerDelegate)]) {
                [(id <DefaultsManagerDelegate>)o observeValue:keyPath change:change];
            }
        }
    }
    [self storeObject:change[@"new"] forKey:keyPath];
}

/**
 Compares two objects from defaults plist and NSUserDefaults
 Cant just use == or isEqual because of the different classes stored

 @param one first object to compare
 @param two second objecct to compare
 @return if they are equal
 */
-(BOOL)compareDefaultsObject:(id)one two:(id) two {

    //two strings
    if ([one isKindOfClass:[NSString class]] && [two isKindOfClass:[NSString class]]) {
        return [(NSString *)one isEqualToString:(NSString *)two];
    }
    //two numbers
    if ([one isKindOfClass:[NSNumber class]] && [two isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)one isEqualToNumber:(NSNumber *)two];
    }
    if ([one isKindOfClass:[NSArray class]] && [two isKindOfClass:[NSArray class]]) {
        return [(NSArray *)one isEqualToArray:(NSArray *)two];
    }
    //both nil
    if (one == nil && two == nil) {
        return YES;
    }
    //different classes, so return NO
    return NO;
}

/**
 Checks to see if an key observing action has happened within a specified amount of time

 @param key key to check
 @return yes, if it happened after threshold
 */
-(BOOL)timeThresholdForKeyPathExceeded:(NSString *)key {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        (void) mach_timebase_info(&_sTimebaseInfo);
    });
    _previousTime = _newTime;
    _newTime = mach_absolute_time();
    
    if(_previousTime > 0) {
        _elapsed = _newTime - _previousTime;
        _elapsedNano = _elapsed * _sTimebaseInfo.numer / _sTimebaseInfo.denom;
    }
    if(_elapsedNano > PFObserverTimeThreshold || ![key isEqualToString:_previousKeyPath]) {
        _previousKeyPath = key;
        return YES;
    }
    return NO;
}

/**
 Sets an array of keys that will be called on NSUserDefaults changes

 @param observer object that we are observing from
 @param keys array of keys to observe
 */
-(void)observeDefaults:(NSObject *)observer keys:(NSArray *)keys {
    //add the observers to our array
    for (NSString* key in keys) {
        //if there is no observer-key array, make one and add our object
        if (self.observers[key] == nil) {
            NSMutableArray *a = [[NSMutableArray alloc] init];
            [a addObject:observer];
            self.observers[key] = a;
        } else { //otherwise see if the object is already in there, if not, add it
            if (![self.observers[key] containsObject:observer]) {
                [self.observers[key] addObject:observer];
            }
        }
        //make sure we add the key as an observer
        if (self.kvos[key] == nil) {
            NSUserDefaults *d = self.standardDefaults;
            [d addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
            self.kvos[key] = @YES;
        }
    }
}

/**
 Removes observers from defaults

 @param observer object that was observed from
 @param keys array of keys to remove as observers
 */
-(void)removeDefaultsObservers:(NSObject *)observer keys:(NSArray *)keys  {
    //remove the observer from the array, so it will be deallocated
    for(NSString *key in self.observers) {
        if ([keys containsObject:key]) {
            [self.observers[key] removeObject:observer];
        }
    }
}
+(BOOL)useSharedDataSource {
    return _useSharedDataSource;
}
+(void)setUseSharedDataSource:(BOOL)useSharedDataSource {
    _useSharedDataSource = useSharedDataSource;
}
@end
