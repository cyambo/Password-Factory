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
 Displays an error message and code with a note to email support

 @param errorDescription error description
 @param code PFErrorCode
 */
-(void)displayError:(NSString *)errorDescription code:(PFErrorCode)code {
    NSString *m = NSLocalizedString(@"applicationErrorMessage", comment: :@"An application error has occurred.\nCode: %ld\nDescription: '%@'\nPlease send an email to\n%@\nwith the code and description");
    NSString *message = [NSString stringWithFormat:m,code,errorDescription,SupportEmailAddress];
    [self displayAlert:message defaultsKey:nil window:nil];
}
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
    DefaultsManager *d = [DefaultsManager get];
    
    if (defaultsKey != nil) {
        //no defaults key set, so make a new one with NO by default
        if ([d objectForKey:defaultsKey] == nil) {
            [d setBool:NO forKey:defaultsKey];
        }
    }
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
        //use a sheet if we are not a menu app, in the preferences window, or if the window is nil
        if (window != nil && (![d boolForKey:@"isMenuApp"] || [window isKindOfClass:[PreferencesWindow class]])) {
            [window beginSheet:self.window completionHandler:nil];
        } else {
            if(window != nil) {
                NSRect popoverFrame = window.frame;
                NSRect windowFrame = self.window.frame;
                //moving alert directly to the left of the popover window
                NSRect newFrame = NSMakeRect(popoverFrame.origin.x - windowFrame.size.width - 20, popoverFrame.origin.y + 50, windowFrame.size.width, windowFrame.size.height);
                [self.window setFrame:newFrame display:YES];
            }
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
