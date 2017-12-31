//
//  NSString+AccentedCase.m
//  Password Factory
//
//  Created by Cristiana Yambo on 10/30/17.
//  Copyright © 2017 Cristiana Yambo. All rights reserved.
//

#import "NSString+AccentedCase.h"
#import "NSString+MapCase.h"
static NSDictionary *map = nil;
@implementation NSString (AccentedCase)
-(NSString *)accentedCase:(NSUInteger)percent {
    if (map == nil) {
        map = @{
                @"a" : @[@"à",@"á",@"â",@"ã",@"ā",@"ă",@"ȧ",@"ä",@"å",@"ǎ",@"ȁ",@"ȃ",@"ą",@"ạ",@"ḁ",@"ằ",@"ǡ",@"ǟ",@"ậ",@"ặ",@"ⱥ",@"ɐ"],
                @"b" : @[@"ḃ",@"ɓ",@"ḅ",@"ḇ",@"ƃ",@"ƅ",@"ƀ"],
                @"c" : @[@"ć",@"ĉ",@"ċ",@"č",@"ƈ",@"ç",@"ḉ",@"ȼ"],
                @"d" : @[@"ḋ",@"ɗ",@"ḍ",@"ḏ",@"ḑ",@"ḓ",@"ď",@"ð",@"đ",@"ɖ",@"ƌ"],
                @"e" : @[@"è",@"é",@"ê",@"ẽ",@"ē",@"ĕ",@"ė",@"ë",@"ě",@"ȅ",@"ȇ",@"ẹ",@"ȩ",@"ę",@"ḙ",@"ḛ",@"ệ",@"ḝ",@"ǝ",@"ɇ",@"ɛ",@"ə"],
                @"f" : @[@"ḟ",@"ƒ"],
                @"g" : @[@"ǵ",@"ĝ",@"ḡ",@"ğ",@"ġ",@"ǧ",@"ɠ",@"ģ"],
                @"h" : @[@"ĥ",@"ḧ",@"ȟ",@"ḥ",@"ḩ",@"ḫ",@"ħ",@"ⱨ",@"ƕ"],
                @"i" : @[@"ì",@"í",@"î",@"ĩ",@"ī",@"ĭ",@"i",@"̇",@"ï",@"ǐ",@"ị",@"į",@"ȉ",@"ȋ",@"ḭ",@"ɨ"],
                @"j" : @[@"ĵ",@"ɉ"],
                @"k" : @[@"ḱ",@"ǩ",@"ḵ",@"ƙ",@"ḳ",@"ķ",@"ⱪ"],
                @"l" : @[@"ĺ",@"ḻ",@"ḷ",@"ļ",@"ḽ",@"ľ",@"ŀ",@"ł",@"ḹ",@"ƚ",@"ⱡ",@"ɫ"],
                @"m" : @[@"ḿ",@"ṁ",@"ṃ",@"ɱ",@"ɯ"],
                @"n" : @[@"ǹ",@"ń",@"ñ",@"ṅ",@"ň",@"ŋ",@"ɲ",@"ṇ",@"ņ",@"ṋ",@"ṉ",@"ƞ"],
                @"o" : @[@"ò",@"ó",@"ô",@"õ",@"ō",@"ŏ",@"ȯ",@"ö",@"ő",@"ǒ",@"ȍ",@"ȏ",@"ơ",@"ǫ",@"ọ",@"ɵ",@"ø",@"ȱ",@"ȫ",@"ȭ",@"ờ",@"ớ",@"ỡ",@"ợ",@"ǭ",@"ộ",@"ǿ"],
                @"p" : @[@"ṗ",@"ƥ"],
                @"q" : @[@"ɋ"],
                @"r" : @[@"ŕ",@"ṙ",@"ř",@"ȑ",@"ȓ",@"ṛ",@"ŗ",@"ṟ",@"ṝ",@"ʀ",@"ɍ",@"ɽ"],
                @"s" : @[@"ś",@"ŝ",@"ṡ",@"š",@"ṣ",@"ș",@"ş",@"ȿ",@"ṩ",@"ƨ"],
                @"t" : @[@"ṫ",@"ť",@"ƭ",@"ʈ",@"ṭ",@"ț",@"ţ",@"ṱ",@"ṯ",@"ŧ",@"ⱦ"],
                @"u" : @[@"ù",@"ú",@"û",@"ũ",@"ū",@"ŭ",@"ü",@"ů",@"ű",@"ǔ",@"ȕ",@"ȗ",@"ư",@"ụ",@"ṳ",@"ų",@"ṷ",@"ṵ",@"ǜ",@"ǘ",@"ǖ",@"ǚ",@"ừ",@"ứ",@"ữ",@"ự",@"ʉ"],
                @"v" : @[@"ṽ",@"ṿ",@"ʋ",@"ʌ"],
                @"w" : @[@"ẁ",@"ẃ",@"ŵ",@"ẇ",@"ẅ",@"ẉ"],
                @"x" : @[@"ẋ",@"ẍ"],
                @"y" : @[@"ỳ",@"ý",@"ŷ",@"ỹ",@"ȳ",@"ẏ",@"ÿ",@"ƴ",@"ỵ",@"ɏ"],
                @"z" : @[@"ź",@"ẑ",@"ż",@"ž",@"ȥ",@"ẓ",@"ẕ",@"ƶ",@"ɀ",@"ⱬ"],
                @"A" : @[@"À",@"Á",@"Â",@"Ã",@"Ā",@"Ă",@"Ȧ",@"Ä",@"Å",@"Ǎ",@"Ȁ",@"Ȃ",@"Ą",@"Ạ",@"Ḁ",@"Ằ",@"Ǡ",@"Ǟ",@"Ậ",@"Ặ",@"Ⱥ",@"Ɐ"],
                @"B" : @[@"Ḃ",@"Ɓ",@"Ḅ",@"Ḇ",@"Ƃ",@"Ƅ",@"Ƀ"],
                @"C" : @[@"Ć",@"Ĉ",@"Ċ",@"Č",@"Ƈ",@"Ç",@"Ḉ",@"Ȼ"],
                @"D" : @[@"Ḋ",@"Ɗ",@"Ḍ",@"Ḏ",@"Ḑ",@"Ḓ",@"Ď",@"Ð",@"Đ",@"Ɖ",@"Ƌ"],
                @"E" : @[@"È",@"É",@"Ê",@"Ẽ",@"Ē",@"Ĕ",@"Ė",@"Ë",@"Ě",@"Ȅ",@"Ȇ",@"Ẹ",@"Ȩ",@"Ę",@"Ḙ",@"Ḛ",@"Ệ",@"Ḝ",@"Ǝ",@"Ɇ",@"Ɛ",@"Ə"],
                @"F" : @[@"Ḟ",@"Ƒ"],
                @"G" : @[@"Ǵ",@"Ĝ",@"Ḡ",@"Ğ",@"Ġ",@"Ǧ",@"Ɠ",@"Ģ"],
                @"H" : @[@"Ĥ",@"Ḧ",@"Ȟ",@"Ḥ",@"Ḩ",@"Ḫ",@"Ħ",@"Ⱨ",@"Ƕ"],
                @"I" : @[@"Ì",@"Í",@"Î",@"Ĩ",@"Ī",@"Ĭ",@"İ",@"Ï",@"Ǐ",@"Ị",@"Į",@"Ȉ",@"Ȋ",@"Ḭ",@"Ɨ"],
                @"J" : @[@"Ĵ",@"Ɉ"],
                @"K" : @[@"Ḱ",@"Ǩ",@"Ḵ",@"Ƙ",@"Ḳ",@"Ķ",@"Ⱪ"],
                @"L" : @[@"Ĺ",@"Ḻ",@"Ḷ",@"Ļ",@"Ḽ",@"Ľ",@"Ŀ",@"Ł",@"Ḹ",@"Ƚ",@"Ⱡ",@"Ɫ"],
                @"M" : @[@"Ḿ",@"Ṁ",@"Ṃ",@"Ɱ",@"Ɯ"],
                @"N" : @[@"Ǹ",@"Ń",@"Ñ",@"Ṅ",@"Ň",@"Ŋ",@"Ɲ",@"Ṇ",@"Ņ",@"Ṋ",@"Ṉ",@"Ƞ"],
                @"O" : @[@"Ò",@"Ó",@"Ô",@"Õ",@"Ō",@"Ŏ",@"Ȯ",@"Ö",@"Ő",@"Ǒ",@"Ȍ",@"Ȏ",@"Ơ",@"Ǫ",@"Ọ",@"Ɵ",@"Ø",@"Ȱ",@"Ȫ",@"Ȭ",@"Ở",@"Ợ",@"Ǭ",@"Ộ",@"Ǿ"],
                @"P" : @[@"Ṗ",@"Ƥ",@"Ᵽ"],
                @"Q" : @[@"Ɋ"],
                @"R" : @[@"Ŕ",@"Ṙ",@"Ř",@"Ȑ",@"Ȓ",@"Ṛ",@"Ŗ",@"Ṟ",@"Ṝ",@"Ʀ",@"Ɍ",@"Ɽ"],
                @"S" : @[@"Ś",@"Ŝ",@"Ṡ",@"Š",@"Ṣ",@"Ș",@"Ş",@"Ṩ",@"Ƨ"],
                @"T" : @[@"Ṫ",@"Ť",@"Ƭ",@"Ʈ",@"Ṭ",@"Ț",@"Ţ",@"Ṱ",@"Ṯ",@"Ŧ",@"Ⱦ"],
                @"U" : @[@"Ù",@"Ú",@"Û",@"Ũ",@"Ū",@"Ŭ",@"Ü",@"Ů",@"Ű",@"Ǔ",@"Ȕ",@"Ȗ",@"Ư",@"Ụ",@"Ṳ",@"Ų",@"Ṷ",@"Ṵ",@"Ǜ",@"Ǘ",@"Ǖ",@"Ǚ",@"Ừ",@"Ứ",@"Ữ",@"Ự",@"Ʉ"],
                @"V" : @[@"Ṽ",@"Ṿ",@"Ʋ",@"Ʌ"],
                @"W" : @[@"Ẁ",@"Ẃ",@"Ŵ",@"Ẇ",@"Ẅ",@"Ẉ"],
                @"X" : @[@"Ẋ",@"Ẍ"],
                @"Y" : @[@"Ỳ",@"Ý",@"Ŷ",@"Ỹ",@"Ȳ",@"Ẏ",@"Ÿ",@"Ƴ",@"Ỵ",@"Ɏ"],
                @"Z" : @[@"Ź",@"Ẑ",@"Ż",@"Ž",@"Ȥ",@"Ẓ",@"Ẕ",@"Ƶ",@"Ⱬ"]
                };
    }

    
    return [self mapCase:percent map:map];
}
@end
