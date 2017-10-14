//
//  AppDelegate.m
//  Password Factory Helper
//
//  Created by Cristiana Yambo on 10/13/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Check if main app is already running; if yes, do nothing and terminate helper app
    BOOL alreadyRunning = NO;
    NSArray *running = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *app in running) {
        if ([[app bundleIdentifier] isEqualToString:@"com.cloudthirteen.Password-Factory"]) {
            alreadyRunning = YES;
        }
    }
    
    if (!alreadyRunning) {
//        NSString *path = [[NSBundle mainBundle] bundlePath];
//        NSArray *p = [path pathComponents];
//        NSMutableArray *pathComponents = [NSMutableArray arrayWithArray:p];
//        [pathComponents removeLastObject];
//        [pathComponents removeLastObject];
//        [pathComponents removeLastObject];
//        [pathComponents addObject:@"MacOS"];
//        [pathComponents addObject:@"Password Factory"];
//        NSString *newPath = [NSString pathWithComponents:pathComponents];
//        [[NSWorkspace sharedWorkspace] launchApplication:newPath];
        NSString *appPath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent]  stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
        // get to the waaay top. Goes through LoginItems, Library, Contents, Applications
        [[NSWorkspace sharedWorkspace] launchApplication:appPath];
        
        
    }
    [NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
