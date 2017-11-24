//
//  DefaultsManager.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/19/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "DefaultsManager.h"
#import "constants.h"
@interface DefaultsManager ()
@property (nonatomic, strong) NSUserDefaults *sharedDefaults;
@property (nonatomic, strong) NSUserDefaults *standardDefaults;
@end
@implementation DefaultsManager

static BOOL loadedPrefs;
static NSDictionary *prefsPlist;


/**
 Singleton Get method

 @return DefaultsManager instance
 */
+(instancetype) get {
    static DefaultsManager *dm = nil;
    
    static dispatch_once_t once = 0;
    
    dispatch_once(&once, ^ {
        dm = [[DefaultsManager alloc] init];

    });
    //always sync shared defaults on get
    [dm syncSharedDefaults];
    return dm;
}
-(instancetype)init {
    self = [super init];
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SharedDefaultsAppGroup];
    self.standardDefaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"SHARED DEFAULTS %@",self.sharedDefaults);
    NSLog(@"STANDARD DEFAULTS %@",self.standardDefaults);
    [self loadPreferencesFromPlist];
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
//    assert([s objectForKey:@"passwordLength"] != nil);
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
    NSUserDefaults *d = [self standardDefaults];
    //taking plist and finding the dialogs and resetting them to not hide
    for (NSString *k in prefsPlist) {
        //check to see if it has Warning as a suffix which all dialogs have
        if ([k hasSuffix:@"Warning"]) {
            [d setBool:NO forKey:k];
        }
    }
    [self syncSharedDefaults];
}
/**
 Gets the key and adds 'Shared' if we are using shared

 @param key key to get
 @return returned key
 */
-(NSString *)getKey:(NSString *)key {
    if (self.useShared) {
        return [NSString stringWithFormat:@"%@Shared",key];
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
 stringForKey on defaults

 @param key key to get
 @return String from defaults
 */
- (NSString *)stringForKey:(NSString *)key {
    return [[self getDefaults] stringForKey:[self getKey:key]];
}
/**
 integerForKey on defaults
 
 @param key key to get
 @return integer from defaults
 */
- (NSInteger)integerForKey:(NSString *)key {
    return [[self getDefaults] integerForKey:[self getKey:key]];
}

/**
 boolForKey on defaults
 
 @param key key to get
 @return bool from defaults
 */
- (BOOL)boolForKey:(NSString *)key {
    return [[self getDefaults] boolForKey:[self getKey:key]];
}
/**
 Makes sure our preferences are loaded only at launch
 */
-(void)loadPreferencesFromPlist {
    if (!loadedPrefs) {
        [self getPrefsFromPlist:false];
        loadedPrefs = YES;
    }
}
/**
 Loads our defaults.plist into a dictionary
 */
-(void)loadDefaultsPlist {
    if (prefsPlist == nil) {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
        prefsPlist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
}
/**
 Takes our defaults plist dictionary and merges it with standardUserDefaults so that our prefs are always set
 */
- (void)getPrefsFromPlist:(BOOL)initialize {
    [self loadDefaultsPlist];
    NSUserDefaults *d = self.standardDefaults;
    
    //taking plist and filling in defaults if none set
    for (NSString *k in prefsPlist) {
        if (initialize || ([d objectForKey:k] == nil)) {
            [d setObject:[prefsPlist objectForKey:k] forKey:k];
        }
    }
    [self syncSharedDefaults];
}
/**
 Syncs our plist with the sharedDefaults manager for use in the today extension
 */
-(void)syncSharedDefaults {
    [self loadDefaultsPlist];
    NSUserDefaults *sharedDefaults = self.sharedDefaults;
    NSUserDefaults *d = self.standardDefaults;
    for (NSString *key in prefsPlist) {
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
@end
