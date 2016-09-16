#import <UIKit/UIKit.h>

@interface NSDate (Manager)

+ (NSDate*)dateOnlyFromServer:(NSString *)dateString;
+ (NSDate*)dateTimeFromServer:(NSString *)dateString;

- (NSString *)shortStyleDateOnly;
- (NSString *)mediumStyleDateOnly;

- (NSString *)serverFormatDateOnly;
- (NSString *)serverFormat;

- (NSDate *)dateOnly;
- (NSInteger)daysUntil:(NSDate *)endDate;
- (BOOL)isSameDay:(NSDate *)otherDate;

@end
