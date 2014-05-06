//
//  PasswordGenerator.h
//  Passsword Generator
//
//  Created by Cristiana Yambo on 5/2/14.
//  Copyright (c) 2014 c13. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordGenerator : NSObject
@property (nonatomic, assign) NSInteger passwordLength;
@property (nonatomic, assign) BOOL useSymbols;
@property (nonatomic, assign) BOOL avoidAmbiguous;
@property (nonatomic, assign) BOOL mixedCase;


- (NSString *)generatePronounceable:(NSString *)selectedTitle;
- (NSString *)generateRandom;
- (NSString *)generatePattern: (NSString *)pattern;
@end
