//
//  StoredPasswordColumn.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "StoredPasswordColumn.h"
#import "StyleKit.h"
@implementation StoredPasswordColumn

/**
 Returns the header cell with the header icon in place

 @return header cell
 */
-(id)headerCell {
    NSCell *c = [super headerCell];
    if (self.columnType) {
        if ([self.columnType isEqualToString:@"type"]) {
            c.image = [StyleKit imageOfPasswordTypeHeader];
        } else if ([self.columnType isEqualToString:@"strength"]) {
            c.image = [StyleKit imageOfPasswordStrengthHeader];
        } else if ([self.columnType isEqualToString:@"password"]) {
            c.image = [StyleKit imageOfPasswordHeader];
        }

    }
    return c;
}
@end
