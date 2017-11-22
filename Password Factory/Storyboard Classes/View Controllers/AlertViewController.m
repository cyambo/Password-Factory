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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)changeHideCheckbox:(NSButton *)sender {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    [d setBool:(sender.state == NSControlStateValueOn) forKey:self.defaultsKey];
}

- (IBAction)clickedOK:(NSButton *)sender {
    [self.alertWindowController closeWindow:NO];
}

- (IBAction)clickedCancel:(NSButton *)sender {
    [self.alertWindowController closeWindow:YES];
}
@end
