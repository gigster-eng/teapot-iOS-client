#import <Foundation/Foundation.h>

typedef void(^CompletionBlock)(id dictionary, NSError *error);

@interface Connection : NSObject

- (id)initWithConfiguration:(NSURLSessionConfiguration*)sessionConfiguration;
+ (NSNumber *)errorStatusCode:(NSError *)error;
+ (NSDictionary *)errorBody:(NSError *)error;

- (NSURLSessionDataTask*)loginProvidersCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;

- (NSURLSessionDataTask*)registerCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;


- (NSURLSessionDataTask*)listingsFilterCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)listingsRecommendedCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)listingsSearchCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)productSearchCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)suggestionsCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)createUpdateListing:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)userProfileCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)greetingCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)friendsListCall:(NSString*)userId completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)createMessageCall:(NSDictionary*)message completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)getMessageThreadsCall:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)getMessageThreadCall:(NSString*)messageThreadId completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)getListingCall:(NSString*)listingId completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)markMessagesReadCall:(NSString*)listingId otherUserId:(NSString*)otherUserId completionBlock:(CompletionBlock)completionBlock;
- (NSURLSessionDataTask*)getSettings:(CompletionBlock)completionBlock;

@end
