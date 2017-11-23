//
//  AppDelegate.m
//  Password Factory Helper
//
//  Created by Cristiana Yambo on 10/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "AppDelegate.h"
#import "constants.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Check if main app is already running; if yes, do nothing and terminate helper app
    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        if ([[app bundleIdentifier] isEqualToString:AppIdentifier]) {
            alreadyRunning = YES;
        }
    }
    
    if (!alreadyRunning) {
        NSMutableArray *path = (NSMutableArray *)[[[NSBundle mainBundle] bundlePath] pathComponents];
        if ([(NSString *)[path objectAtIndex:path.count -2] isEqualToString:@"LoginItems"]) { //check to see if we are running within the main app
            path = [[path subarrayWithRange:NSMakeRange(0, path.count - 3)] mutableCopy]; //Remove last three items from path - Library/LoginItems/Password Factory Helper.App
            [path addObjectsFromArray:@[@"MacOS",@"Password Factory"]]; //Add the relative path to the app executable to absolute path
            BOOL didRun = [[NSWorkspace sharedWorkspace] launchApplication:[NSString pathWithComponents:path]]; //try to start the app
            if (!didRun) {
                NSLog(@"App didn't start from helper");
            }
        } else {
            NSLog(@"Helper app was not installed properly");
        }

    }
    [NSApp terminate:nil]; //kill the helper
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (IBAction)exportPasswords:(id)sender {
}
@end
