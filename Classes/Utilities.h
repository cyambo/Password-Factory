//
//  Utilities.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject
+(BOOL)isDarkMode;
+(NSAttributedString *)colorText:(NSString *)text size:(NSUInteger)size;
+(NSColorSpace *)colorSpace;
@end
