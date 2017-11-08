//
//  PasswordStrength.h
//  Password Factory
//
//  Created by Cristiana Yambo on 12/4/15.
//  Copyright © 2015 Cristiana Yambo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasswordStrength : NSObject
@property (nonatomic, strong) NSString *crackTimeString;
@property (nonatomic, assign) float strength;
-(void)updatePasswordStrength:(NSString *)password withCrackTimeString:(BOOL)withCt;
@end
