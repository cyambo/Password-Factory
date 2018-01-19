//
//  Passwords+CoreDataProperties.h
//  
//
//  Created by Cristiana Yambo on 1/18/18.
//
//

#import "Passwords+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Passwords (CoreDataProperties)

+ (NSFetchRequest<Passwords *> *)fetchRequest;

@property (nonatomic) int16_t length;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *passwordID;
@property (nonatomic) float strength;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nonatomic) int16_t type;
@property (nonatomic) BOOL synced;

@end

NS_ASSUME_NONNULL_END
