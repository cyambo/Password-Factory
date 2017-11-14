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
        dm.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:SharedDefaultsAppGroup];
        dm.standardDefaults = [NSUserDefaults standardUserDefaults];
        [dm loadPreferencesFromPlist];
    });
    return dm;
}

/**
 Gets the shared defaults for the app

 @return shared defaults
 */
+(NSUserDefaults *)sharedDefaults {
    return [DefaultsManager get].sharedDefaults;
}

/**
 Gets the standardUserDefaults

 @return standard defaults
 */
+(NSUserDefaults *)standardDefaults {
    return [DefaultsManager get].standardDefaults;
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
            NSLog(@"KEY %@",k);
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
    //TODO: save table selection
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
