//
//  DefaultsManager.m
//  Password Factory
//
//  Created by Cristiana Yambo on 8/19/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "DefaultsManager.h"
@interface DefaultsManager ()
@property (nonatomic, strong) NSUserDefaults *sharedDefaults;
@end
@implementation DefaultsManager
+(instancetype) get {
    static DefaultsManager *dm = nil;
    
    static dispatch_once_t once = 0;
    
    
    dispatch_once(&once, ^ {
        dm = [[DefaultsManager alloc] init];
        dm.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"XWE2VMM384.com.cloudthirteen.password-factory"];
    });
    return dm;
}
+(NSUserDefaults *)sharedDefaults {
    return [DefaultsManager get].sharedDefaults;
}
@end
