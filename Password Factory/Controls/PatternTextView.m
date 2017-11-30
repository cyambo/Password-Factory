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

-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    [self appendText:[d stringForKey:@"userPattern"]];
    self.delegate = self;
    return self;
}
-(void)textDidChange:(NSNotification *)notification {
    [self setDefaults];
}

- (NSTouchBar *)makeTouchBar {
    NSTouchBar *bar = [[NSTouchBar alloc] init];
    bar.delegate = self;
    bar.defaultItemIdentifiers = @[@"CharacterInsert"];
    return bar;
}

- (IBAction)insertCharacter:(NSSegmentedControl *)sender {
    NSString *title = [sender labelForSegment:sender.selectedSegment];
    [self appendText:title];

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
