//
//  AppDelegate.m
//  Password Factory Helper
//
//  Created by Cristiana Yambo on 10/14/17.
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
        NSMutableArray *path = (NSMutableArray *)[[[NSBundle mainBundle] bundlePath] pathComponents];
        path = [[path subarrayWithRange:NSMakeRange(0, path.count - 3)] mutableCopy];
        [path addObjectsFromArray:@[@"MacOS",@"Password Factory"]];
        BOOL didRun = [[NSWorkspace sharedWorkspace] launchApplication:[NSString pathWithComponents:path]];
        if (!didRun) {
            NSLog(@"App didn't start from helper");
        }
    }
    [NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
