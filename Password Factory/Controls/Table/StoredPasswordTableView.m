//
//  StoredPasswordTableView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "StoredPasswordTableView.h"

@implementation StoredPasswordTableView

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.columnAutoresizingStyle = NSTableViewUniformColumnAutoresizingStyle;
    return self;
}


@end
