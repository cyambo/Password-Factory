//
//  TodayViewController.m
//  Password Factory Widget
//
//  Created by Cristiana Yambo on 8/17/15.
//  Copyright (c) 2015 Cristiana Yambo. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "PasswordFactory.h"
@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, strong) PasswordFactory *factory;
@end

@implementation TodayViewController

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    self.factory = [[PasswordFactory alloc] init];
    NSUserDefaults *sd = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.cloud13.password-factory"];
    
    completionHandler(NCUpdateResultNoData);
}

- (IBAction)generatePassword:(id)sender {
}

- (IBAction)copyPassword:(id)sender {
}
- (IBAction)selectPasswordType:(id)sender {
}
@end

