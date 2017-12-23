//
//  Passwords+CoreDataProperties.h
//  
//
//  Created by Cristiana Yambo on 12/22/17.
//
//

#import "Passwords+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Passwords (CoreDataProperties)

+ (NSFetchRequest<Passwords *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *password;
@property (nonatomic) float strength;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nonatomic) int16_t type;
@property (nonatomic) int16_t length;

@end

NS_ASSUME_NONNULL_END
