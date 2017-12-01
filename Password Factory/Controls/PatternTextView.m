//
//  PatternTextView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/28/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PatternTextView.h"
#import "PasswordFactoryConstants.h"
#import "DefaultsManager.h"
@implementation PatternTextView


/**
 Initializes the TextView with defaults text

 @param coder default coder
 @return self
 */
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    [self setText:[d stringForKey:@"userPattern"]];
    self.delegate = self;
    return self;
}

/**
 NSTextViewDelegate method

 @param notification default notification
 */
-(void)textDidChange:(NSNotification *)notification {
    [self setDefaults];
}

/**
 Makes the touchBar for the text view

 @return touchbar
 */
- (NSTouchBar *)makeTouchBar {
    NSTouchBar *bar = [[NSTouchBar alloc] init];
    bar.delegate = self;
    bar.defaultItemIdentifiers = @[@"CharacterInsert"];
    return bar;
}

/**
 Inerts pattern character from the touchbar

 @param sender default sender
 */
- (IBAction)insertCharacter:(NSSegmentedControl *)sender {
    NSString *title = [sender labelForSegment:sender.selectedSegment];
    [self appendText:title];

}

/**
 Touchbar method to generate touchbar items

 @param touchBar default
 @param identifier default
 @return touchbar item
 */
- (nullable NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier {
    
    if ([identifier isEqualToString:@"CharacterInsert"]) {
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:@"CharacterInsert"];
        NSSegmentedControl *insertControl = [[NSSegmentedControl alloc] init];
        PasswordFactoryConstants *c = [PasswordFactoryConstants get];
        [insertControl setSegmentCount:c.patternCharacterToType.count];
        
        for(int i = 0; i < c.patternCharacterToType.count; i++) {
            PFPatternTypeItem type = [c getPatternTypeByIndex:i];
            NSString * key = c.patternTypeToCharacter[@(type)];
            [insertControl setLabel:key forSegment:i];
            [insertControl setWidth:32.0 forSegment:i];
        }
        [insertControl setAction:@selector(insertCharacter:)];
        touchBarItem.view = insertControl;
        touchBarItem.customizationLabel = @"Insert Pattern Character";
        return touchBarItem;
    }
    return nil;
}
@end
