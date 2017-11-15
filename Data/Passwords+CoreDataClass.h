//
//  Passwords+CoreDataClass.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <SyncKit/QSPrimaryKey.h>

NS_ASSUME_NONNULL_BEGIN

@interface Passwords : NSManagedObject <QSPrimaryKey>

@end

NS_ASSUME_NONNULL_END

#import "Passwords+CoreDataProperties.h"
