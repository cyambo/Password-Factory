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
#import "Utilities.h"
#import "NSString+ColorWithHexColorString.h"
@implementation PatternTextView


/**
 Initializes the TextView with defaults text

 @param coder default coder
 @return self
 */
-(instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    DefaultsManager *d = [DefaultsManager get];
    [self setText:[d stringForKey:@"userPattern"]];
    self.delegate = self;
    return self;
}
-(void)awakeFromNib {
    [super awakeFromNib];
    [self colorPatternText];
    NSUserDefaults *d = [DefaultsManager standardDefaults];
    [d addObserver:self forKeyPath:@"colorPasswordText" options:NSKeyValueObservingOptionNew context:NULL];
    [d addObserver:self forKeyPath:@"AppleInterfaceStyle" options:NSKeyValueObservingOptionNew context:NULL];
}
/**
 NSTextViewDelegate method

 @param notification default notification
 */
-(void)textDidChange:(NSNotification *)notification {
    [self setDefaults];
    [self colorPatternText];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self colorPatternText];
}

-(void)colorPatternText {
    NSDictionary *defaultAttributes = @{
                                        NSFontAttributeName: [NSFont systemFontOfSize:self.textSize],
                                        NSForegroundColorAttributeName: [[[DefaultsManager get] stringForKey:@"defaultTextColor"] colorWithHexColorString]
                                        };
    __block NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:self.textStorage.string attributes:defaultAttributes];
    if([[DefaultsManager get] boolForKey:@"colorPasswordText"]) {

        PasswordFactoryConstants *c = [PasswordFactoryConstants get];
        [s beginEditing];
        
        [self.textStorage.string enumerateSubstringsInRange:NSMakeRange(0, self.textStorage.string.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable at, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            if(substringRange.length == 1) { //only color strings with length of one, anything greater is an emoji or other long unicode charcacters
                PFPatternTypeItem t = (PFPatternTypeItem)[(NSNumber *)c.patternCharacterToType[at] integerValue];
                //set the character color
                NSColor *c = [self getPatternColor:t];
                [s addAttribute:NSForegroundColorAttributeName value:c range:substringRange];
            }
        }];
        [s endEditing];
        
    }
    [self.textStorage setAttributedString:s];
}
-(NSColor *)getPatternColor:(PFPatternTypeItem)type {
    NSString *colorString = [[DefaultsManager get] stringForKey:@"defaultTextColor"];
    switch (type) {
        case PFNumberType:
            colorString = @"ce9740";
            break;
        case PFLowerCaseWordType:
            colorString = @"ceb340";
            break;
        case PFUpperCaseWordType:
            colorString = @"ccce40";
            break;
        case PFRandomCaseWordType:
            colorString = @"99bf3c";
            break;
        case PFTitleCaseWordType:
            colorString = @"38b23f";
            break;
        case PFLowerCaseShortWordType:
            colorString = @"3891b2";
            break;
        case PFUpperCaseShortWordType:
            colorString = @"3867b2";
            break;
        case PFRandomCaseShortWordType:
            colorString = @"4f38b2";
            break;
        case PFTitleCaseShortWordType:
            colorString = @"8e38b2";
            break;
        case PFSymbolType:
            colorString = @"ba3a7f";
            break;
        case PFLowerCaseCharacterType:
            colorString = @"ce4340";
            break;
        case PFUpperCaseCharacterType:
            colorString = @"cf8e27";
            break;
        case PFNonAmbiguousCharacterType:
            colorString = @"cfb027";
            break;
        case PFNonAmbiguousUpperCaseCharacterType:
            colorString = @"cbcd27";
            break;
        case PFNonAmbiguousNumberType:
            colorString = @"8dbd24";
            break;
        case PFLowerCasePhoneticSoundType:
            colorString = @"21ad2e";
            break;
        case PFUpperCasePhoneticSoundType:
            colorString = @"2186ad";
            break;
        case PFRandomCasePhoneticSoundType:
            colorString = @"2155ad";
            break;
        case PFTitleCasePhoneticSoundType:
            colorString = @"3e21ad";
            break;
        case PFEmojiType:
            colorString = @"8721ad";
            break;
        case PFRandomItemType:
            colorString = @"b72370";
            break;
    }
    if ([Utilities isDarkMode]) {
        return [Utilities dodgeColor:[colorString colorWithHexColorString] backgroundColor:[Utilities getBackgroundColor]];
    } else {
       return [colorString colorWithHexColorString];
    }
    
}
-(void)setText:(NSString *)text {
    [super setText:text];
    [self colorPatternText];
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
