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
 @param defaultsKey key to check in defaults that will show and hide alert
 */
-(void)displayAlert:(NSString *)alert defaultsKey:(NSString *)defaultsKey {
    [self displayAlertWithBlock:alert defaultsKey:defaultsKey closeBlock:nil];
}
-(void)displayAlertWithBlock:(NSString *)alert defaultsKey:(NSString *)defaultsKey closeBlock:(void (^)(BOOL cancelled))closeBlock {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    //check to see if we want it hidden
    if (![d boolForKey:defaultsKey]) {
        AlertViewController *a = (AlertViewController *)self.contentViewController;
        [a.cancelButton setHidden:YES];
        [a.alertText setStringValue:alert];
        a.defaultsKey = defaultsKey;
        a.alertWindowController = self;
        self.closeBlock = closeBlock;
        if (closeBlock) {
            [a.cancelButton setHidden:NO];
        } else {
            [a.cancelButton setHidden:YES];
        }
        [self showWindow:nil];
        self.window.delegate = self;
        [self.window makeKeyAndOrderFront:nil];
    }
    //hidden, so do nothing
    
}
-(void)closeWindow:(BOOL)cancelled {
    if(self.closeBlock) {
        self.closeBlock(cancelled);
        self.closeBlock = nil;
    }
    [self.window close];
}
-(void)windowWillClose:(NSNotification *)notification {
    if(self.closeBlock) {
        self.closeBlock(YES);
    }
}
@end
