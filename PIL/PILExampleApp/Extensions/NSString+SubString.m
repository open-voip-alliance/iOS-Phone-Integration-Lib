//
//  NSString+SubString.m
//

#import "NSString+SubString.h"

@implementation NSString (SubString)

- (BOOL)containsString:(NSString *)string {
    NSParameterAssert(string);
    NSRange range = [self rangeOfString:string];
    return (range.location != NSNotFound);
}

- (NSString *)substringBetweenString:(NSString *)startString andString:(NSString *)endString {
    NSString *returnString = nil;
    if ([self containsString:startString]) {
        NSScanner *scanner = [NSScanner scannerWithString:self];
        [scanner scanUpToString:startString intoString:nil];
        NSInteger firstStop = [scanner scanLocation];
        [scanner setScanLocation:firstStop + [startString length]];
        [scanner scanUpToString:endString intoString:&returnString];
    }
    return returnString;
}
@end
