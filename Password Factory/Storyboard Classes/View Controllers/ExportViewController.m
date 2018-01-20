//
//  ExportViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/22/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "ExportViewController.h"
#import "PasswordController.h"
#import "constants.h"
#import "PasswordStorage.h"
#import "AppDelegate.h"
@interface ExportViewController ()
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) BOOL showType;
@property (nonatomic, assign) BOOL showStrength;

@end

@implementation ExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
-(void)viewWillAppear {
    NSDictionary *types = [[PasswordController get] getFilteredPasswordTypes];
    NSArray *keys = [[types allKeys] sortedArrayUsingSelector:@selector(compare:)];
    [self.passwordTypes removeAllItems];
    for(int i = 0; i < keys.count; i++) {
        PFPasswordType t = [(NSNumber *)keys[i] integerValue];
        NSString *name = types[keys[i]];
        [self.passwordTypes addItemWithTitle:name];
        [self.passwordTypes itemAtIndex:i].tag = t;
    }
    [self.progress stopAnimation:nil];
    self.queue = [[NSOperationQueue alloc] init];
    
}

/**
 Exports passwords to disk

 @param sender default sender
 */
- (IBAction)export:(NSButton *)sender {
    if (self.queue.operations.firstObject) {
        //already running an export, so cancel
        [self.queue cancelAllOperations];

        [self.exportButton setTitle:@"Export"];
    } else {
        NSSavePanel *panel = [NSSavePanel savePanel];
        panel.allowedFileTypes = @[@"csv"];
        NSInteger clicked = [panel runModal];

        if (clicked == NSFileHandlingPanelOKButton) {
            [self.exportButton setTitle:@"Cancel"];
            NSString *path = panel.URL.path;
            if ([[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
                __block NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:path append:YES];
                [stream open];
                PFPasswordType type = self.passwordTypes.selectedItem.tag;
                NSUInteger amount = [self.exportAmount integerValue];
                self.showType = self.exportType.state == NSControlStateValueOn;
                self.showStrength = self.exportStrength.state == NSControlStateValueOn;
                [self.progress startAnimation:nil];
                if (type != PFStoredType) {
                    [self generatePasswords:type stream:stream amount:amount];
                } else {
                    [self exportStored:stream];
                }
            } else {
                AppDelegate *d = [NSApplication sharedApplication].delegate;
                [d.alertWindowController displayAlert:PasswordSaveError defaultsKey:nil window:self.view.window];
            }

        }

    }

}

/**
 Exports all passwords from storage

 @param stream Stream to output to
 */
-(void)exportStored:(NSOutputStream *)stream {
    __block PasswordStorage *storage = [PasswordStorage get];
    __block PasswordController *pvc = [PasswordController get];
    __block ExportViewController *s = self;
    __block NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        //write header line
        [s writeStringToStream:stream string:[s getCSVLine:@"Password" typeName:@"Type" strength:@"Strength"]];
        for(int i = 0; i < [storage count]; i++) {
            if ([op isCancelled]) { //stop if we are cancelled
                break;
            }
            Passwords *p = [storage passwordAtIndex:i];
            if (p.password != nil) {
                NSString *strength = [[NSNumber numberWithInteger:(int)p.strength] stringValue];
                NSString *typeName = [pvc getNameForPasswordType:(PFPasswordType)p.type];
                [s writeStringToStream:stream string:[s getCSVLine:p.password typeName:typeName strength:strength]];
            }
        }
        [stream close];
        dispatch_async(dispatch_get_main_queue(), ^{
            [s.exportButton setTitle:@"Export"];
            [s.progress stopAnimation:nil];
        });
    }];
    
    [self.queue addOperation:op];
}

/**
 Generates passwords to be stored

 @param type PFPasswordType
 @param stream stream to output to
 @param amount number of passwords to generate
 */
-(void)generatePasswords:(PFPasswordType)type stream:(NSOutputStream *)stream amount:(NSInteger)amount {
    __block PasswordController *p = [PasswordController get];
    NSString *typeName = [p getNameForPasswordType:type];
    __block NSMutableDictionary *settings = [[p getPasswordSettingsByType:type] mutableCopy];
    settings[@"noDisplay"] = @(YES);
    __block ExportViewController *s = self;
    __block NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        //write header line
        [s writeStringToStream:stream string:[s getCSVLine:@"Password" typeName:@"Type" strength:@"Strength"]];
        for(int i = 0; i < amount; i++) {
            if ([op isCancelled]) { //stop if we are cancelled
                break;
            }
            
            [p generatePassword:type withSettings:settings];
            NSString *strength = [[NSNumber numberWithInteger:(int)[p getPasswordStrength]] stringValue];
            [s writeStringToStream:stream string:[s getCSVLine:p.password typeName:typeName strength:strength]];
            
            if (type == PFAdvancedType) {
                //get new settings every time for advanced type
                settings = [[p getPasswordSettingsByType:type] mutableCopy];
                settings[@"noDisplay"] = @(YES);
            }
        }
        [stream close];
        dispatch_async(dispatch_get_main_queue(), ^{
            [s.exportButton setTitle:@"Export"];
            [s.progress stopAnimation:nil];
        });
    }];
    
    [self.queue addOperation:op];
}

/**
 Writes a string to output stream

 @param stream stream to output to
 @param string string to output
 */
-(void)writeStringToStream:(NSOutputStream *)stream string:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF16StringEncoding];
    [stream write:[data bytes] maxLength:data.length];
}

/**
 Generates the CSV line for output, will hide and show Type and Strength columns based upon settings

 @param password password to output
 @param typeName type of the password
 @param strength strength
 @return CSV Line
 */
-(NSString *)getCSVLine:(NSString *)password typeName:(NSString *)typeName strength:(NSString *)strength {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    //show the type
    if(self.showType) {
        [output addObject:typeName];
    }
    //escaping quotes so we don't break the csv file
    password = [password stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    password = [NSString stringWithFormat:@"\"%@\"",password];
    [output addObject:password];
    //show the strength
    if(self.showStrength) {
           [output addObject:strength];
    }
    return [NSString stringWithFormat:@"%@\n",[output componentsJoinedByString:@","]];
}

/**
 Called when password type is changed, will disable amount when stored is selected because all ae output

 @param sender default sender
 */
- (IBAction)changePasswordType:(NSPopUpButton *)sender {
    if(self.passwordTypes.selectedItem.tag == PFStoredType) {
        [self.exportAmount setEnabled:NO];
    } else {
        [self.exportAmount setEnabled:YES];
    }
}
@end
