//
//  AlertViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/22/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "AlertViewController.h"
#import "DefaultsManager.h"
@interface AlertViewController ()

@end

@implementation AlertViewController


-(void)viewWillAppear {
    [super viewWillAppear];
    //hide the checkbox if the defaults key is nil
    if(self.defaultsKey == nil) {
        [self.hideCheckbox setHidden:YES];
    } else {
        [self.hideCheckbox setHidden:NO];
        self.hideCheckbox.state = NSControlStateValueOff;
    }
}

/**
 Called when the hide checkbox is updated

 @param sender default sender
 */
- (IBAction)changeHideCheckbox:(NSButton *)sender {
    DefaultsManager *d = [DefaultsManager get];
    [d setBool:(sender.state == NSControlStateValueOn) forKey:self.defaultsKey];
}

/**
 Clicked OK and closes window

 @param sender default sender
 */
- (IBAction)clickedOK:(NSButton *)sender {
    [self.alertWindowController closeWindow:NO];
}

/**
 Clicked cancel and closes window
 
 @param sender default sender
 */
- (IBAction)clickedCancel:(NSButton *)sender {
    [self.alertWindowController closeWindow:YES];
}
@end
