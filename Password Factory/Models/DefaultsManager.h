//
//  DefaultsManager.h
//  Password Factory
//
//  Created by Cristiana Yambo on 8/19/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DefaultsManager;
@protocol DefaultsManagerDelegate <NSObject>
- (void)observeValue:(NSString *  _Nullable)keyPath change:( NSDictionary * _Nullable)change;
@end
@interface DefaultsManager : NSObject
@property (nonatomic, strong) NSDictionary   * _Nullable prefsPlist;
@property (class, nonatomic, assign) BOOL useSharedDataSource;
+(instancetype _Nonnull) get;
+(NSUserDefaults *_Nonnull)sharedDefaults;
+(NSUserDefaults *_Nonnull)standardDefaults;
+(void)restoreUserDefaults;
+(void)removeRemoteDefaults;
-(void)resetDialogs;
- (void)enableRemoteStore:(BOOL)enable;
- (NSString * _Nullable)stringForKey:(NSString * _Nonnull)key;
- (NSInteger)integerForKey:(NSString * _Nonnull)key;
- (BOOL)boolForKey:(NSString * _Nonnull)key;
- (float)floatForKey:(NSString * _Nonnull)key;
-(id _Nullable)objectForKey:(NSString * _Nonnull)key;
-(void)storeObject:(id _Nullable)object forKey:(NSString * _Nonnull)keyPath;
-(void)setObject:(id _Nullable)object forKey:(NSString * _Nonnull)key;
-(void)setBool:(BOOL)object forKey:(NSString * _Nonnull)key;
-(void)setInteger:(NSInteger)object forKey:(NSString * _Nonnull)key;
-(void)setFloat:(float)object forKey:(NSString * _Nonnull)key;
-(BOOL)timeThresholdForKeyPathExceeded:(NSString * _Nonnull)key;
-(void)observeDefaults:(NSObject * _Nonnull)observer keys:(NSArray * _Nonnull)keys;
-(void)removeDefaultsObservers:(NSObject *  _Nonnull)observer keys:(NSArray *  _Nonnull)keys;
-(void)disableRemoteSyncForKeys:(NSArray *_Nonnull)keys;
@end
