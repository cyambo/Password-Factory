//
//  AlertWindowController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/22/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AlertWindowController : NSWindowController
-(void)displayAlert:(NSString *)alert defaultsKey:(NSString *)defaultsKey ;
@end
