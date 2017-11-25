//
//  PatternTextView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/25/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PatternTextView.h"
#import "PasswordFactoryConstants.h"
@interface PatternTextView ()

@end
@implementation PatternTextView


- (NSTouchBar *)makeTouchBar {
    
    NSTouchBar *bar = [super makeTouchBar];
    bar.delegate = self;
    
    // Set the default ordering of items.
    bar.defaultItemIdentifiers =
    @[@"CharacterInsert"];
    
    return bar;
}
- (IBAction)insertCharacter:(NSSegmentedControl *)sender {

}
- (nullable NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier {

    if ([identifier isEqualToString:@"CharacterInsert"]) {
        NSCustomTouchBarItem *touchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:@"CharacterInsert"];
        NSSegmentedControl *insertControl = [[NSSegmentedControl alloc] init];
        PasswordFactoryConstants *c = [PasswordFactoryConstants get];
        [insertControl setSegmentCount:c.patternCharacterToType.count];
        int i = 0;
        for(NSString *key in c.patternCharacterToType) {
            [insertControl setLabel:key forSegment:i];
            i++;
        }
        [insertControl setAction:@selector(insertCharacter:)];
        touchBarItem.view = insertControl;
        touchBarItem.customizationLabel = @"Insert Pattern Character";
        return touchBarItem;
    }
    return nil;
}


@end
