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
#import "PreferencesWindow.h"
@interface AlertWindowController ()
@property (nonatomic, copy) void (^closeBlock)(BOOL cancelled);
@end

@implementation AlertWindowController

/**
 Displays the alert message if we did not explicitly turn it off

 @param alert alert message to show
 @param defaultsKey  key to check in defaults that will show and hide alert (if nil it will hide the checkbox to hide the alert)
 @param window window to show sheet on
 */
-(void)displayAlert:(NSString *)alert defaultsKey:(NSString *)defaultsKey window:(NSWindow *)window {
    [self displayAlertWithBlock:alert defaultsKey:defaultsKey window:window closeBlock:nil];
}

/**
 Displays the alert message if we did not explicitly turn it off
 
 @param alert alert message to show
 @param defaultsKey  key to check in defaults that will show and hide alert (if nil it will hide the checkbox to hide the alert)
 @param window window to show sheet on
 @param closeBlock block that is called on close, will send YES if the operation was cancelled
 */
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
        if (![d boolForKey:@"isMenuApp"] || [window isKindOfClass:[PreferencesWindow class]]) {
            [window beginSheet:self.window completionHandler:nil];
        } else {
            [self showWindow:nil];
            [self.window makeKeyAndOrderFront:nil];
        }
        
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
