//
//  PreferencesWindowController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/2/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "PreferencesViewController.h"
@interface PreferencesWindowController ()
- (void)resetShortcutRegistration;
@end

@implementation PreferencesWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    //setting up window close notification
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    
//    registering for notification that the window is closing to run shortcut set code
//    this is because it seems to 'forget' the key when preferences is loaded
        [notification addObserver:self
                         selector:@selector(resetShortcutRegistration)
                             name:NSWindowWillCloseNotification
                           object:self.window];
}

/**
 Calls resetShortcutRegistration on ViewController
 */
- (void)resetShortcutRegistration {
    PreferencesViewController *vc = (PreferencesViewController *)self.contentViewController;
    [vc resetShortcutRegistration];
}
@end
