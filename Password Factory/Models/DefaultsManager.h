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
-(void)resetDialogs;
-(void)syncSharedDefaults;
@property (nonatomic, assign) BOOL useShared;
- (void)enableShared:(BOOL)enable;
- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
-(id)objectForKey:(NSString *)key;
-(void)setObject:(id)object forKey:(NSString *)key;
-(void)setBool:(BOOL)object forKey:(NSString *)key;
-(void)setInteger:(NSInteger)object forKey:(NSString *)key;
-(void)setFloat:(float)object forKey:(NSString *)key;
@end
