//
//  DefaultsManager.h
//  Password Factory
//
//  Created by Cristiana Yambo on 8/19/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DefaultsManager : NSObject
+(instancetype) get;
+(NSUserDefaults *)sharedDefaults;
+(NSUserDefaults *)standardDefaults;
+(void)restoreUserDefaults;
-(void)syncSharedDefaults;
@end
