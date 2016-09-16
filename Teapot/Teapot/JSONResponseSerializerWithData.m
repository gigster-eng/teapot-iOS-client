#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
  id JSONObject = [super responseObjectForResponse:response data:data error:error];
  if (*error != nil) {
    NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
    [userInfo setValue:[response valueForKey:@"statusCode"] forKey:kJSONStatusCodeKey];
    if (JSONObject != nil) {
      [userInfo setValue:JSONObject forKey:kJSONBodyKey];
    }
    NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
    (*error) = newError;
  }
  
  return (JSONObject);
}

@end
