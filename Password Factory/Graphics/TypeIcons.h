//
//  TypeIcons.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

@interface TypeIcons : NSObject
+(NSImage *)getTypeIcon:(PFPasswordType)type;
+(NSImage *)getAlternateTypeIcon:(PFPasswordType)type;
@end
