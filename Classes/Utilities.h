//
//  Utilities.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/17/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Utilities : NSObject
+(BOOL)isDarkMode;
+(NSAttributedString *)colorText:(NSString *)text size:(NSUInteger)size;
+(NSColorSpace *)colorSpace;
+(uint)randomInt:(uint)limit;
@end
