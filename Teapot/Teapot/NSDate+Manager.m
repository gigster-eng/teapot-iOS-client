#import "NSDate+Manager.h"

#define kFormatInDateTime @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"
#define kFormatOutDateTime @"yyyy-MM-dd'T'HH:mm:ssZZZ"
#define kFormatDateOnly @"yyyy-MM-dd"

@implementation NSDate (Manager)

#pragma mark - public

+ (NSDate*)dateOnlyFromServer:(NSString *)dateString {
    return [self dateFromServerString:dateString withFormat:kFormatDateOnly];
}

+ (NSDate*)dateTimeFromServer:(NSString *)dateString {
    return [self dateFromServerString:dateString withFormat:kFormatInDateTime];
}

- (NSString *)shortStyleDateOnly {
    return [[self dateFormatter:NSDateFormatterShortStyle] stringFromDate:self];
}

- (NSString *)mediumStyleDateOnly {
    return [[self dateFormatter:NSDateFormatterMediumStyle] stringFromDate:self];
}

- (NSDateFormatter *)dateFormatter:(NSDateFormatterStyle)dateFormatterStyle {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:dateFormatterStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return dateFormatter;
}

- (NSString *)serverFormat {
    return [self stringWithFormat:kFormatOutDateTime forceLocaleAndUTC:YES];
}

- (NSString *)serverFormatDateOnly {
    return [self stringWithFormat:kFormatDateOnly forceLocaleAndUTC:YES];
}

- (NSDate *)dateOnly {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    return [calendar dateFromComponents:components];
}

- (NSInteger)daysUntil:(NSDate *)endDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:self
                                                 toDate:endDate
                                                options:0];
    return [components day];
}

- (BOOL)isSameDay:(NSDate *)otherDate {
    return [self.dateOnly isEqualToDate:otherDate.dateOnly];
}

#pragma mark - helpers

+ (NSDate*)dateFromServerString:(NSString *)dateString withFormat:(NSString *)format {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
//    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return [dateFormatter dateFromString:dateString];
}

- (NSString *)stringWithFormat:(NSString *)format {
    return [self stringWithFormat:format forceLocaleAndUTC:NO];
}

- (NSString *)stringWithFormat:(NSString *)format forceLocaleAndUTC:(BOOL)forceLocaleAndUTC {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    if (forceLocaleAndUTC) {
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    
    return [formatter stringFromDate:self];
}

- (NSString *)month{
    return [self stringWithFormat:@"MMM"];
}

- (NSString *)day{
    return [self stringWithFormat:@"dd"];
}

- (NSString *)year{
    return [self stringWithFormat:@"YYYY"];
}

@end
