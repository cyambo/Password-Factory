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
    [self setFont:[NSFont systemFontOfSize:32]];
    [self setMaxSize:NSMakeSize(FLT_MAX, self.frame.size.height)];
    [self setHorizontallyResizable:YES];
    [self.textContainer setWidthTracksTextView:NO];
    [self.textContainer setContainerSize:NSMakeSize(FLT_MAX, self.frame.size.height)];
    [self addText:[d stringForKey:@"userPattern"]];
    self.delegate = self;
    return self;
}
-(void)textDidChange:(NSNotification *)notification {
    [self setDefaults];
}
-(void)setDefaults {
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    if (![self.textStorage.string isEqualToString:[d stringForKey:@"userPattern"]]) {
       [d setObject:self.textStorage.string forKey:@"userPattern"];
    }
}
- (NSTouchBar *)makeTouchBar {
    NSTouchBar *bar = [[NSTouchBar alloc] init];
    bar.delegate = self;
    bar.defaultItemIdentifiers = @[@"CharacterInsert"];
    return bar;
}
-(NSDictionary *)getTextAttributes {
    return @{
             NSFontAttributeName: [NSFont systemFontOfSize:32]
             };
}
-(void)addText:(NSString *)text {
    if (text != nil && text.length) {
        NSDictionary *attributes = [self getTextAttributes];
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        [self.textStorage appendAttributedString:string];
        [self setDefaults];
    }
}
-(void)resetText:(NSString *)text {
    if(text == nil) {
        text = @"";
    }
    NSDictionary *attributes = [self getTextAttributes];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [self.textStorage setAttributedString:string];
    [self setDefaults];
}
- (IBAction)insertCharacter:(NSSegmentedControl *)sender {
    NSString *title = [sender labelForSegment:sender.selectedSegment];
    [self addText:title];

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
