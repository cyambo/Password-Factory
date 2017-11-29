//
//  PatternTextView.m
//  Password Factory
//
//  Created by Cristiana Yambo on 11/25/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "PatternTextField.h"
#import "constants.h"
#import "PasswordFactoryConstants.h"
@interface PatternTextField ()

@end
@implementation PatternTextField


- (NSTouchBar *)makeTouchBar {
    
    NSTouchBar *bar = [[NSTouchBar alloc] init];
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
