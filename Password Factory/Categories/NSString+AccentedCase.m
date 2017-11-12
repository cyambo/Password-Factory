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
                @"a" : @[@"à",@"á",@"â",@"ã",@"ā",@"ă",@"ȧ",@"ä",@"ả",@"å",@"ǎ",@"ȁ",@"ȃ",@"ą",@"ạ",@"ḁ",@"ầ",@"ấ",@"ẫ",@"ẩ",@"ằ",@"ắ",@"ẵ",@"ẳ",@"ǡ",@"ǟ",@"ǻ",@"ậ",@"ặ",@"ⱥ",@"ɐ"],
                @"b" : @[@"ḃ",@"ɓ",@"ḅ",@"ḇ",@"ƃ",@"ƅ",@"ƀ"],
                @"c" : @[@"ć",@"ĉ",@"ċ",@"č",@"ƈ",@"ç",@"ḉ",@"ȼ"],
                @"d" : @[@"ḋ",@"ɗ",@"ḍ",@"ḏ",@"ḑ",@"ḓ",@"ď",@"ð",@"đ",@"ɖ",@"ƌ"],
                @"e" : @[@"è",@"é",@"ê",@"ẽ",@"ē",@"ĕ",@"ė",@"ë",@"ẻ",@"ě",@"ȅ",@"ȇ",@"ẹ",@"ȩ",@"ę",@"ḙ",@"ḛ",@"ề",@"ế",@"ễ",@"ể",@"ḕ",@"ḗ",@"ệ",@"ḝ",@"ǝ",@"ɇ",@"ɛ",@"ə"],
                @"f" : @[@"ḟ",@"ƒ"],
                @"g" : @[@"ǵ",@"ĝ",@"ḡ",@"ğ",@"ġ",@"ǧ",@"ɠ",@"ģ",@"ǥ"],
                @"h" : @[@"ĥ",@"ḧ",@"ȟ",@"ḥ",@"ḩ",@"ḫ",@"ħ",@"ⱨ",@"ƕ"],
                @"i" : @[@"ì",@"í",@"î",@"ĩ",@"ī",@"ĭ",@"i",@"̇",@"ï",@"ỉ",@"ǐ",@"ị",@"į",@"ȉ",@"ȋ",@"ḭ",@"ɨ",@"ḯ"],
                @"j" : @[@"ĵ",@"ɉ"],
                @"k" : @[@"ḱ",@"ǩ",@"ḵ",@"ƙ",@"ḳ",@"ķ",@"ⱪ"],
                @"l" : @[@"ĺ",@"ḻ",@"ḷ",@"ļ",@"ḽ",@"ľ",@"ŀ",@"ł",@"ḹ",@"ƚ",@"ⱡ",@"ɫ"],
                @"m" : @[@"ḿ",@"ṁ",@"ṃ",@"ɱ",@"ɯ"],
                @"n" : @[@"ǹ",@"ń",@"ñ",@"ṅ",@"ň",@"ŋ",@"ɲ",@"ṇ",@"ņ",@"ṋ",@"ṉ",@"ƞ"],
                @"o" : @[@"ò",@"ó",@"ô",@"õ",@"ō",@"ŏ",@"ȯ",@"ö",@"ỏ",@"ő",@"ǒ",@"ȍ",@"ȏ",@"ơ",@"ǫ",@"ọ",@"ɵ",@"ø",@"ồ",@"ố",@"ỗ",@"ổ",@"ȱ",@"ȫ",@"ȭ",@"ṍ",@"ṑ",@"ṓ",@"ờ",@"ớ",@"ỡ",@"ở",@"ợ",@"ǭ",@"ộ",@"ǿ"],
                @"p" : @[@"ṗ",@"ƥ",@"ᵽ"],
                @"q" : @[@"ɋ"],
                @"r" : @[@"ŕ",@"ṙ",@"ř",@"ȑ",@"ȓ",@"ṛ",@"ŗ",@"ṟ",@"ṝ",@"ʀ",@"ɍ",@"ɽ"],
                @"s" : @[@"ś",@"ŝ",@"ṡ",@"š",@"ṣ",@"ș",@"ş",@"ȿ",@"ṥ",@"ṧ",@"ṩ",@"ƨ"],
                @"t" : @[@"ṫ",@"ť",@"ƭ",@"ʈ",@"ṭ",@"ț",@"ţ",@"ṱ",@"ṯ",@"ŧ",@"ⱦ"],
                @"u" : @[@"ù",@"ú",@"û",@"ũ",@"ū",@"ŭ",@"ü",@"ủ",@"ů",@"ű",@"ǔ",@"ȕ",@"ȗ",@"ư",@"ụ",@"ṳ",@"ų",@"ṷ",@"ṵ",@"ṹ",@"ṻ",@"ǜ",@"ǘ",@"ǖ",@"ǚ",@"ừ",@"ứ",@"ữ",@"ử",@"ự",@"ʉ"],
                @"v" : @[@"ṽ",@"ṿ",@"ʋ",@"ʌ"],
                @"w" : @[@"ẁ",@"ẃ",@"ŵ",@"ẇ",@"ẅ",@"ẉ",@"ⱳ"],
                @"x" : @[@"ẋ",@"ẍ"],
                @"y" : @[@"ỳ",@"ý",@"ŷ",@"ỹ",@"ȳ",@"ẏ",@"ÿ",@"ỷ",@"ƴ",@"ỵ",@"ɏ"],
                @"z" : @[@"ź",@"ẑ",@"ż",@"ž",@"ȥ",@"ẓ",@"ẕ",@"ƶ",@"ɀ",@"ⱬ"],
                @"A" : @[@"À",@"Á",@"Â",@"Ã",@"Ā",@"Ă",@"Ȧ",@"Ä",@"Ả",@"Å",@"Ǎ",@"Ȁ",@"Ȃ",@"Ą",@"Ạ",@"Ḁ",@"Ầ",@"Ấ",@"Ẫ",@"Ẩ",@"Ằ",@"Ắ",@"Ẵ",@"Ẳ",@"Ǡ",@"Ǟ",@"Ǻ",@"Ậ",@"Ặ",@"Ⱥ",@"Ɐ"],
                @"B" : @[@"Ḃ",@"Ɓ",@"Ḅ",@"Ḇ",@"Ƃ",@"Ƅ",@"Ƀ"],
                @"C" : @[@"Ć",@"Ĉ",@"Ċ",@"Č",@"Ƈ",@"Ç",@"Ḉ",@"Ȼ"],
                @"D" : @[@"Ḋ",@"Ɗ",@"Ḍ",@"Ḏ",@"Ḑ",@"Ḓ",@"Ď",@"Ð",@"Đ",@"Ɖ",@"Ƌ"],
                @"E" : @[@"È",@"É",@"Ê",@"Ẽ",@"Ē",@"Ĕ",@"Ė",@"Ë",@"Ẻ",@"Ě",@"Ȅ",@"Ȇ",@"Ẹ",@"Ȩ",@"Ę",@"Ḙ",@"Ḛ",@"Ề",@"Ế",@"Ễ",@"Ể",@"Ḕ",@"Ḗ",@"Ệ",@"Ḝ",@"Ǝ",@"Ɇ",@"Ɛ",@"Ə"],
                @"F" : @[@"Ḟ",@"Ƒ"],
                @"G" : @[@"Ǵ",@"Ĝ",@"Ḡ",@"Ğ",@"Ġ",@"Ǧ",@"Ɠ",@"Ģ",@"Ǥ"],
                @"H" : @[@"Ĥ",@"Ḧ",@"Ȟ",@"Ḥ",@"Ḩ",@"Ḫ",@"Ħ",@"Ⱨ",@"Ƕ"],
                @"I" : @[@"Ì",@"Í",@"Î",@"Ĩ",@"Ī",@"Ĭ",@"İ",@"Ï",@"Ỉ",@"Ǐ",@"Ị",@"Į",@"Ȉ",@"Ȋ",@"Ḭ",@"Ɨ",@"Ḯ"],
                @"J" : @[@"Ĵ",@"Ɉ"],
                @"K" : @[@"Ḱ",@"Ǩ",@"Ḵ",@"Ƙ",@"Ḳ",@"Ķ",@"Ⱪ"],
                @"L" : @[@"Ĺ",@"Ḻ",@"Ḷ",@"Ļ",@"Ḽ",@"Ľ",@"Ŀ",@"Ł",@"Ḹ",@"Ƚ",@"Ⱡ",@"Ɫ"],
                @"M" : @[@"Ḿ",@"Ṁ",@"Ṃ",@"Ɱ",@"Ɯ"],
                @"N" : @[@"Ǹ",@"Ń",@"Ñ",@"Ṅ",@"Ň",@"Ŋ",@"Ɲ",@"Ṇ",@"Ņ",@"Ṋ",@"Ṉ",@"Ƞ"],
                @"O" : @[@"Ò",@"Ó",@"Ô",@"Õ",@"Ō",@"Ŏ",@"Ȯ",@"Ö",@"Ỏ",@"Ő",@"Ǒ",@"Ȍ",@"Ȏ",@"Ơ",@"Ǫ",@"Ọ",@"Ɵ",@"Ø",@"Ồ",@"Ố",@"Ỗ",@"Ổ",@"Ȱ",@"Ȫ",@"Ȭ",@"Ṍ",@"Ṑ",@"Ṓ",@"Ờ",@"Ớ",@"Ỡ",@"Ở",@"Ợ",@"Ǭ",@"Ộ",@"Ǿ"],
                @"P" : @[@"Ṗ",@"Ƥ",@"Ᵽ"],
                @"Q" : @[@"Ɋ"],
                @"R" : @[@"Ŕ",@"Ṙ",@"Ř",@"Ȑ",@"Ȓ",@"Ṛ",@"Ŗ",@"Ṟ",@"Ṝ",@"Ʀ",@"Ɍ",@"Ɽ"],
                @"S" : @[@"Ś",@"Ŝ",@"Ṡ",@"Š",@"Ṣ",@"Ș",@"Ş",@"Ȿ",@"Ṥ",@"Ṧ",@"Ṩ",@"Ƨ"],
                @"T" : @[@"Ṫ",@"Ť",@"Ƭ",@"Ʈ",@"Ṭ",@"Ț",@"Ţ",@"Ṱ",@"Ṯ",@"Ŧ",@"Ⱦ"],
                @"U" : @[@"Ù",@"Ú",@"Û",@"Ũ",@"Ū",@"Ŭ",@"Ü",@"Ủ",@"Ů",@"Ű",@"Ǔ",@"Ȕ",@"Ȗ",@"Ư",@"Ụ",@"Ṳ",@"Ų",@"Ṷ",@"Ṵ",@"Ṹ",@"Ṻ",@"Ǜ",@"Ǘ",@"Ǖ",@"Ǚ",@"Ừ",@"Ứ",@"Ữ",@"Ử",@"Ự",@"Ʉ"],
                @"V" : @[@"Ṽ",@"Ṿ",@"Ʋ",@"Ʌ"],
                @"W" : @[@"Ẁ",@"Ẃ",@"Ŵ",@"Ẇ",@"Ẅ",@"Ẉ",@"Ⱳ"],
                @"X" : @[@"Ẋ",@"Ẍ"],
                @"Y" : @[@"Ỳ",@"Ý",@"Ŷ",@"Ỹ",@"Ȳ",@"Ẏ",@"Ÿ",@"Ỷ",@"Ƴ",@"Ỵ",@"Ɏ"],
                @"Z" : @[@"Ź",@"Ẑ",@"Ż",@"Ž",@"Ȥ",@"Ẓ",@"Ẕ",@"Ƶ",@"Ɀ",@"Ⱬ"]
                };
    }

    
    return [self mapCase:percent map:map];
}
@end
