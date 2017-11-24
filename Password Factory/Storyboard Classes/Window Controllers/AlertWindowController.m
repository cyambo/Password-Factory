//
//  AlertWindowController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/22/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "AlertWindowController.h"
#import "DefaultsManager.h"
#import "AlertViewController.h"
@interface AlertWindowController ()
@property (nonatomic, copy) void (^closeBlock)(BOOL cancelled);
@end

@implementation AlertWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

/**
 Displays the alert message if we did not explicitly turn it off

 @param alert Alert to show
 @param defaultsKey key to check in defaults that will show and hide alert (if nil it will hide the checkbox to hide the alert)
 */
-(void)displayAlert:(NSString *)alert defaultsKey:(NSString *)defaultsKey window:(NSWindow *)window {
    [self displayAlertWithBlock:alert defaultsKey:defaultsKey window:window closeBlock:nil];
}
-(void)displayAlertWithBlock:(NSString *)alert defaultsKey:(NSString *)defaultsKey window:(NSWindow *)window closeBlock:(void (^)(BOOL cancelled))closeBlock {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    //check to see if we want it hidden
    if (defaultsKey == nil || ![d boolForKey:defaultsKey]) {
        AlertViewController *a = (AlertViewController *)self.contentViewController;
        [a.alertText setStringValue:alert];
        a.defaultsKey = defaultsKey;
        a.alertWindowController = self;
        self.closeBlock = closeBlock;
        if (closeBlock) {
            [a.cancelButton setHidden:NO];
        } else {
            [a.cancelButton setHidden:YES];
        }
        [window beginSheet:self.window completionHandler:nil];
    }
    //hidden, so do nothing
    
}
-(void)closeWindow:(BOOL)cancelled {
    [NSApp stopModal];
    if(self.closeBlock) {
        self.closeBlock(cancelled);
        self.closeBlock = nil;
    }
    [self.window close];
}

@end
