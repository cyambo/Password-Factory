//
//  ZoomViewController.h
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ZoomViewController : NSViewController
- (IBAction)clickedWindow:(NSClickGestureRecognizer *)sender;
- (void)updatePassword:(NSString *)password;
@property (weak) IBOutlet NSTextField *zoomedPassword;
@end
