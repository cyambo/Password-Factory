//
//  StoredPasswordColumn.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/15/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StoredPasswordColumn : NSTableColumn
@property (nonatomic, strong) IBInspectable NSString *columnType;
@end
