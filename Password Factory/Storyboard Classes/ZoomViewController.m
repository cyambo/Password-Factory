//
//  ZoomViewController.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/14/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//


#import "ZoomViewController.h"
#import "constants.h"
@interface ZoomViewController ()
@property (nonatomic, strong) NSDictionary *sizes;
@property (nonatomic, strong) NSDictionary *fonts;
@property (nonatomic, strong) NSArray *sizeOrder;
@property (nonatomic, assign) NSRect screenRect;
@end

@implementation ZoomViewController
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    self.sizeOrder = @[@(PFZoomSmallFontSize),@(PFZoomMediumFontSize),@(PFZoomLargeFontSize),@(PFZoomXLargeFontSize)];
    NSMutableDictionary *f = [[NSMutableDictionary alloc] init];
    for(NSNumber *size in self.sizeOrder) {
        f[size] = [NSFont fontWithName:ZoomFontName size:[size integerValue]];
    }
    self.fonts = f;
    NSMutableDictionary *s = [[NSMutableDictionary alloc] init];
    for(NSNumber *size in self.fonts) {
        NSMutableAttributedString *sizeString = [[NSMutableAttributedString alloc] initWithString:@"W" attributes:@{NSFontAttributeName:self.fonts[size]}];
        s[size] = [NSValue valueWithSize:sizeString.size];
    }
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
 Sets the size of the font and window for the password to be displayed

 @param password attributed string of current password
 */
-(void)updatePassword:(NSAttributedString *)password {
    NSUInteger screenWidth = self.screenRect.size.width;
    NSUInteger passwordLength = password.length;
    NSUInteger whichFont = PFZoomSmallFontSize;
    for(NSNumber *size in self.sizeOrder) {
        NSSize currSize = ((NSValue *)self.sizes[size]).sizeValue;
        if ((currSize.width * passwordLength) < screenWidth) {
            whichFont = [size integerValue];
        } else {
            break;
        }
    }
    
    NSFont *f = [NSFont fontWithName:ZoomFontName size:whichFont];
    __block NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:password.string attributes:@{NSFontAttributeName:f}];
    __block NSUInteger i = 0;
    [s beginEditing];
    [password.string enumerateSubstringsInRange:NSMakeRange(0, password.string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable character, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSDictionary *d = [password attributesAtIndex:i effectiveRange:nil];
        if(d[@"NSColor"]) {
            [s addAttribute:NSForegroundColorAttributeName value:d[@"NSColor"] range:substringRange];
        }
        i++;
    }];
    [s endEditing];

    [self.zoomedPassword.cell setWraps:NO];
    [self.zoomedPassword.cell setScrollable:YES];
    self.zoomedPassword.attributedStringValue = s;

    NSRect wf = self.view.window.frame;
    wf.size = s.size;

    [self.view.window setFrame:wf display:YES];
    [self.view.window center];
}
-(void)setWindowSize {
    
}
@end
