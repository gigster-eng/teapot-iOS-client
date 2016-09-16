// Based on HMFJSONResponseSerializerWithData by Brandon Butler on 10/15/13.

#import "AFURLResponseSerialization.h"

/// NSError userInfo keys that will contain response data
static NSString * const kJSONBodyKey = @"kJSONBodyKey";
static NSString * const kJSONStatusCodeKey = @"kJSONStatusCodeKey";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end
