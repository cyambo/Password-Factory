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
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    
    //check to see if we want it hidden
    if (![d boolForKey:defaultsKey]) {
        AlertViewController *a = (AlertViewController *)self.contentViewController;
        [a.alertText setStringValue:alert];
        a.defaultsKey = defaultsKey;
        a.currentWindow = self.window;
        [self showWindow:nil];
        [self.window makeKeyAndOrderFront:nil];
    }
    //hidden, so do nothing
}
@end
