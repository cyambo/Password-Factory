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

static mach_timebase_info_data_t _sTimebaseInfo;

uint64_t  _newTime, _previousTime, _elapsed, _elapsedNano, _threshold;
NSString  *_previousKeyPath;

@interface DefaultsManager ()
@property (nonatomic, strong) NSUserDefaults *sharedDefaults;
@property (nonatomic, strong) NSUserDefaults *standardDefaults;
@property (nonatomic, strong) NSMutableDictionary *standardDefaultsCache;
@property (nonatomic, strong) NSMutableDictionary *sharedDefaultsCache;

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
            [dm syncToSharedDefaults];
        });
    }
    return dm;
}

/**
 Singleton get method, enables shared and since we are shared
 we do not sync to shared defaults as the shared defaults are the
 definitive source, rather than the main defaults

 @return DefaultsManager Instance
 */
+(instancetype)getShared {
    if(!dm) {
        static dispatch_once_t once = 0;
        dispatch_once(&once, ^ {
            dm = [[DefaultsManager alloc] init];
            [dm enableShared:YES];
        });
    }
    return dm;
}
-(instancetype)init {
    self = [super init];
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SharedDefaultsAppGroup];
    self.standardDefaults = [NSUserDefaults standardUserDefaults];
    [self loadPreferencesFromPlist];
    [self setupCache];
    [self addObservers];
    return self;
}
-(void)enableShared:(BOOL)enable {
    self.useShared = enable;
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
    [[DefaultsManager get] getPrefsFromPlist:true];
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
 Gets the key and adds 'Shared' if we are using shared

 @param key key to get
 @return returned key
 */
-(NSString *)getKey:(NSString *)key {
    if (self.useShared) {
        return [key stringByAppendingString:@"Shared"];
    } else {
        return key;
    }
}

/**
 Gets shared or standard defaults based on useShared

 @return defaults
 */
- (NSUserDefaults *)getDefaults {
    if(self.useShared) {
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
    if(self.useShared) {
        key = [key stringByAppendingString:@"Shared"];
        object = [self.sharedDefaults objectForKey:key];
        cached = [self.sharedDefaultsCache objectForKey:key];
    } else {
        object = [self.standardDefaults objectForKey:key];
        cached = [self.standardDefaultsCache objectForKey:key];
    }
    if (object == nil){
        NSLog(@"FAILED DEFAULTS %@",key);
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
 Sets object in defaults, shared defaults and cache

 @param object object to set
 @param key defaults key
 */
-(void)setObject:(id)object forKey:(NSString *)key {
    if (object == nil) {
        return;
    }
    [self.standardDefaults setObject:object forKey:key];
    [self.standardDefaultsCache setObject:object forKey:key];
    NSString *sharedKey = [key stringByAppendingString:@"Shared"];
    [self.sharedDefaults setObject:object forKey:sharedKey];
    [self.sharedDefaultsCache setObject:object forKey:sharedKey];
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
 Makes sure our preferences are loaded only at launch
 */
-(void)loadPreferencesFromPlist {
    if (!self.prefsPlist) {
        [self getPrefsFromPlist:false];
    }
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
    
    //taking plist and filling in defaults if none set
    for (NSString *k in self.prefsPlist) {
        if (initialize || ([d objectForKey:k] == nil)) {
            [self setObject:[self.prefsPlist objectForKey:k] forKey:k];
        }
    }
}
-(void)addObservers {
    NSUserDefaults *d = self.standardDefaults;
    for (NSString *k in self.prefsPlist) {
        [d addObserver:self forKeyPath:k options:NSKeyValueObservingOptionNew context:NULL];
    }
}
-(void)setupCache {
    NSMutableDictionary *st = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *sh = [[NSMutableDictionary alloc] init];
    NSUserDefaults *d = self.standardDefaults;
    NSUserDefaults *h = self.sharedDefaults;
    for (NSString *k in self.prefsPlist) {
        if([d objectForKey:k] != nil) {
            [st setObject:[d objectForKey:k] forKey:k];
        } else {
            [st setObject:[self.prefsPlist objectForKey:k] forKey:k];
        }
        NSString *sharedKey = [k stringByAppendingString:@"Shared"];
        if([h objectForKey:sharedKey] != nil) {
            [sh setObject:[h objectForKey:sharedKey] forKey:sharedKey];
        } else {
            [sh setObject:[self.prefsPlist objectForKey:k] forKey:sharedKey];
        }
    }
    self.standardDefaultsCache = st;
    self.sharedDefaultsCache = sh;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //don't do anything if the change is null
    if (change[@"new"] == [NSNull null]) {
        return;
    }
    NSString *sharedKeyPath = [keyPath stringByAppendingString:@"Shared"];
    [self.standardDefaultsCache setObject:change[@"new"] forKey:keyPath];
    [self.sharedDefaultsCache setObject:change[@"new"] forKey:sharedKeyPath];
    [self.sharedDefaults setObject:change[@"new"] forKey:sharedKeyPath];
}
/**
 Syncs our plist to the sharedDefaults manager for use in the today extension
 */
-(void)syncToSharedDefaults {
    [self loadDefaultsPlist];
    NSUserDefaults *sharedDefaults = self.sharedDefaults;
    NSUserDefaults *d = self.standardDefaults;
    for (NSString *key in self.prefsPlist) {
        NSString *k = [key stringByAppendingString:@"Shared"]; //Appending shared to shared defaults because KVO will cause the observer to be called
        id obj = [d objectForKey:key];
        //syncing to shared defaults
        if(![self compareDefaultsObject:[sharedDefaults objectForKey:k] two:obj]) {
            [sharedDefaults setObject:[d objectForKey:key] forKey:k];
        }
    }
}
/**
 Compares two objects from defaults plist and NSUserDefaults
 Cant just use == or isEqual because of the different classes stored

 @param one first object to compare
 @param two second objecct to compare
 @return equality of the two
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
    //both nil
    if (one == nil && two == nil) {
        return YES;
    }
    //different classes, so return NO
    return NO;
}

-(BOOL)timeThresholdForKeyPathExceeded:(NSString *)key thresholdValue:(uint64_t)threshold {
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
    NSLog(@"%@ ELAPSDE %llu",key,_elapsedNano);
    if(_elapsedNano > threshold || ![key isEqualToString:_previousKeyPath]) {
        NSLog(@"SUCC");
        _previousKeyPath = key;
        return YES;
    }
    return NO;
}

@end
