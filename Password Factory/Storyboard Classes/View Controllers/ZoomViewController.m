//
//  ZoomViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//


#import "ZoomViewController.h"
#import "NSString+UnicodeLength.h"
#import "constants.h"
#import "Utilities.h"
@interface ZoomViewController ()
@property (nonatomic, strong) NSDictionary *sizes;
@property (nonatomic, strong) NSDictionary *fonts;
@property (nonatomic, strong) NSArray *sizeOrder;
@property (nonatomic, assign) NSRect screenRect;
@property (nonatomic, strong) NSEvent *windowEvent;
@end

@implementation ZoomViewController
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    //sets the array of font sizes in order
    self.sizeOrder = @[@(PFZoomSmallFontSize),@(PFZoomMediumFontSize),@(PFZoomLargeFontSize),@(PFZoomXLargeFontSize)];
    NSMutableDictionary *f = [[NSMutableDictionary alloc] init];
    //sets the NSFont for each of our font sizes
    for(NSNumber *size in self.sizeOrder) {
        f[size] = [NSFont fontWithName:ZoomFontName size:[size integerValue]];
    }
    self.fonts = f;
    //gets the NSSize of each nsfont and sets up our array containing each size
    NSMutableDictionary *s = [[NSMutableDictionary alloc] init];
    for(NSNumber *size in self.fonts) {
        NSMutableAttributedString *sizeString = [[NSMutableAttributedString alloc] initWithString:@"W" attributes:@{NSFontAttributeName:self.fonts[size]}];
        s[size] = [NSValue valueWithSize:sizeString.size];
    }
    //set event to close when you click outside the windwo
    self.windowEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDown handler:^(NSEvent *event) {
        if ([self.view.window isVisible]) {
            [self.view.window close];
        }
    }];
    self.sizes = s;
    
    return self;
}
- (void)viewWillAppear {
    //get the screen size every time to deal with screen size changes
    [self getScreenSize];
    //set the bg color to white
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

/**
 Called when the gesture recognizer is clicked, and closes the window

 @param sender default sender
 */
- (IBAction)clickedWindow:(NSClickGestureRecognizer *)sender {
    [self.view.window close];
}

/**
 Gets the size of the current screen
 */
-(void)getScreenSize {
    if ([NSScreen screens].count) {
        self.screenRect = [[NSScreen screens][0] visibleFrame];
    }
}

/**
 Sets the size of the font and window and displays the password

 @param password attributed string of current password
 */
-(void)updatePassword:(NSString *)password {
    NSUInteger screenWidth = self.screenRect.size.width;
    NSUInteger passwordLength = [password getUnicodeLength];
    NSUInteger whichFont = PFZoomSmallFontSize;
    //determine which font to use
    for(NSNumber *size in self.sizeOrder) {
        NSSize currSize = ((NSValue *)self.sizes[size]).sizeValue;
        //we can just multiply by the password length because it is a fixed width font
        if ((currSize.width * passwordLength) < screenWidth) {
            //not too big
            whichFont = [size integerValue];
        } else {
            //too big, so break
            break;
        }
    }
    __block NSMutableAttributedString *s = [[Utilities colorText:password size:whichFont] mutableCopy];
    //set the bg color to use for alternate letters
    NSColor *bg = [NSColor colorWithRed:0 green:0 blue:0 alpha:0.05];
    //get our font
    NSFont *f = [NSFont fontWithName:ZoomFontName size:whichFont];
    
    __block NSUInteger i = 0;
    [s beginEditing];
    //enumerate through the string
    [password enumerateSubstringsInRange:NSMakeRange(0, password.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {

        //add a bg on alternate letters
        if ((i % 2) == 0) {
            [s addAttribute:NSBackgroundColorAttributeName value:bg range:substringRange];
        }
        [s addAttribute:NSFontAttributeName value:f range:substringRange];
        i++;
    }];
    [s endEditing];

    //set the view settings
    [self.zoomedPassword.cell setWraps:NO];
    [self.zoomedPassword.cell setScrollable:YES];
    self.zoomedPassword.attributedStringValue = s;

    //resize the window to match the password size
    NSRect wf = self.view.window.frame;
    wf.size = s.size;
    //set window posution to be x centered and slightly above center on y
    wf.origin.x = (self.screenRect.size.width - s.size.width)/2;
    wf.origin.y = (self.screenRect.size.height - s.size.height)/2 + (self.screenRect.size.height * 0.1);
    //display the window
    [self.view.window setFrame:wf display:YES];

}
@end
