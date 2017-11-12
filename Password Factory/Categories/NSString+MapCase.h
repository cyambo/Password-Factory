//
//  NSString+MapCase.h
//  Password Factory
//
//  Created by Cristiana Yambo on 10/30/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MapCase)
-(NSString *)mapCase:(NSUInteger)percent map:(NSDictionary *)map;
@end
