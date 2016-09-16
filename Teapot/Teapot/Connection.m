#import "Connection.h"
#import "ConnectionURLS.h"
#import "NSData+PKCS12.h"
#import "JSONResponseSerializerWithData.h"
#import "AFNetworking.h"
#import <Teapot-Swift.h>

@interface Connection()

@property (nonatomic,strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

@implementation Connection

#pragma mark - Initialization

- (id)initWithConfiguration:(NSURLSessionConfiguration*)sessionConfiguration {
    self = [super init];
    if (self) {
        if (!sessionConfiguration) {
            sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        
        self.sessionConfiguration = sessionConfiguration;
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:self.sessionConfiguration];
        self.sessionManager.responseSerializer = [JSONResponseSerializerWithData serializer];
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        [self.sessionManager.requestSerializer setValue:@"application/text" forHTTPHeaderField:@"Content-Type"];
        
        return self;
    }
    return nil;
}

- (NSDictionary*)addTokensToParameter:(NSDictionary*)parameters {

    User* user = [User currentUser];
    NSMutableDictionary *newParameters = parameters ? [parameters mutableCopy] : [[NSMutableDictionary alloc] init];

    [newParameters setObject:[AppConfiguration appId] forKey:@"app"];
    [newParameters setObject:[user id] forKey:@"person_id"];
    return newParameters;
}

- (NSURLSessionDataTask*)loginProvidersCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
    return [self genericGetCall:parameters completionBlock:completionBlock urlString:kLoginProviders];
}


- (NSURLSessionDataTask*)registerCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
    return [self genericPostCall:parameters completionBlock:completionBlock urlString:kUserRegister];
}

- (NSURLSessionDataTask*)listingsFilterCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
    NSDictionary* newDictionary = [self addTokensToParameter:parameters];
    return [self genericGetCall:newDictionary completionBlock:completionBlock urlString:kListingsFilter];
}

- (NSURLSessionDataTask*)listingsRecommendedCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
    NSDictionary* newDictionary = [self addTokensToParameter:parameters];
    return [self genericGetCall:newDictionary completionBlock:completionBlock urlString:kRecommendations];
}

- (NSURLSessionDataTask*)listingsSearchCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
    NSDictionary* newDictionary = [self addTokensToParameter:parameters];
    return [self genericGetCall:newDictionary completionBlock:completionBlock urlString:kListingsSearch];
}

- (NSURLSessionDataTask*)productSearchCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
  return [self genericGetCall:parameters completionBlock:completionBlock urlString:kProductSearch];
}

- (NSURLSessionDataTask*)suggestionsCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
  return [self genericGetCall:parameters completionBlock:completionBlock urlString:kSuggestions];
}

- (NSURLSessionDataTask*)createUpdateListing:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
  return [self genericPostCall:parameters completionBlock:completionBlock urlString:kListingCreate];
}

- (NSURLSessionDataTask*)userProfileCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
  NSString *url = [NSString stringWithFormat:@"%@%@", kUserProfile, [parameters objectForKey:@"person_id"]];
  
  return [self genericGetCall:parameters completionBlock:completionBlock urlString: url];
}

- (NSURLSessionDataTask*)greetingCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
    return [self genericGetCall:parameters completionBlock:completionBlock urlString: kGreeting];
}

- (NSURLSessionDataTask*)friendsListCall:(NSString*)userId completionBlock:(CompletionBlock)completionBlock {
  NSDictionary *parameters = @{@"app": [AppConfiguration appId],
                               @"source_person_id": userId};
  
  return [self genericGetCall:parameters completionBlock:completionBlock urlString: kFriendsList];
}

- (NSURLSessionDataTask*)createMessageCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock {
  return [self genericPostCall:parameters completionBlock:completionBlock urlString:kMessageCreate];
}

- (NSURLSessionDataTask*)getMessageThreadsCall:(CompletionBlock)completionBlock {
  NSDictionary *parameters = @{@"app": [AppConfiguration appId],
                               @"person_id": [[ModelManager sharedManager] getAppID]};
  
  return [self genericGetCall:parameters completionBlock:completionBlock urlString: kMessageThreads];
}

- (NSURLSessionDataTask*)getMessageThreadCall:(NSString*)messageThreadId completionBlock:(CompletionBlock)completionBlock {
  NSDictionary *parameters = @{@"app": [AppConfiguration appId],
                               @"viewer_user_id": [[ModelManager sharedManager] getAppID],
                               @"message_thread_id": messageThreadId};
  
  return [self genericGetCall:parameters completionBlock:completionBlock urlString: kMessageThreadDetail];
}

- (NSURLSessionDataTask*)getListingCall:(NSString*)listingId completionBlock:(CompletionBlock)completionBlock {
  NSDictionary *parameters = @{@"app": [AppConfiguration appId],
                               @"viewer_user_id": [[ModelManager sharedManager] getAppID],
                               @"listing_id": listingId};
  
  return [self genericGetCall:parameters completionBlock:completionBlock urlString: kListingGet];
}


- (NSURLSessionDataTask*)markMessagesReadCall:(NSString*)listingId otherUserId:(NSString*)otherUserId completionBlock:(CompletionBlock)completionBlock {
  NSDictionary *parameters = @{@"app": [AppConfiguration appId],
                               @"viewer_person_id": [[ModelManager sharedManager] getAppID],
                               @"other_person_id": otherUserId,
                               @"listing_id": listingId};
  
  return [self genericPostCall:parameters completionBlock:completionBlock urlString: kMessageMarkRead];
}

- (NSURLSessionDataTask*)getSettings:(CompletionBlock)completionBlock {
  NSDictionary *parameters = @{@"app": [AppConfiguration appId]};
  
  return [self genericGetCall:parameters completionBlock:completionBlock urlString: kSettings];
}

#pragma mark - Response Handling

- (void)connectionSuccess:(CompletionBlock)completionBlock responseObject:(id)responseObject {
    if(completionBlock) completionBlock(responseObject,nil);
}

- (void)connectionFail:(CompletionBlock)completionBlock
                  task:(NSURLSessionDataTask *)task
                 error:(NSError *)error {
    
    [self logConnectionError:error task:task];
    
    if(completionBlock) completionBlock(nil, error);
}

- (void)logConnectionError:(NSError *)error task:(NSURLSessionDataTask *)task {
    NSLog(@"[Connection] Status Code: %@, Body: %@", [Connection errorStatusCode:error], [Connection errorBody:error]);
}

+ (NSNumber *)errorStatusCode:(NSError *)error {
    return [error.userInfo objectForKey:kJSONStatusCodeKey];
}

+ (NSDictionary *)errorBody:(NSError *)error {
    return [error.userInfo objectForKey:kJSONBodyKey];
}

#pragma mark - Request Handling

- (NSURLSessionDataTask*)genericGetCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock urlString:(NSString*)urlString {
    
    return [self.sessionManager GET:urlString
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                [self connectionSuccess:completionBlock responseObject:responseObject];
                                
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                [self connectionFail:completionBlock task:task error:error];
                            }];
}

- (NSURLSessionDataTask*)genericPutCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock urlString:(NSString*)urlString {
    
    return [self.sessionManager PUT:urlString
                         parameters:parameters
                            success:^(NSURLSessionDataTask *task, id responseObject) {
                                [self connectionSuccess:completionBlock responseObject:responseObject];
                                
                            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                [self connectionFail:completionBlock task:task error:error];
                            }];
}

- (NSURLSessionDataTask*)genericPostCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock urlString:(NSString*)urlString {
    
    return [self.sessionManager POST:urlString
                          parameters:parameters
                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                 [self connectionSuccess:completionBlock responseObject:responseObject];
                             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                 [self connectionFail:completionBlock task:task error:error];
                             }];
}

- (NSURLSessionDataTask*)genericDeleteCall:(NSDictionary*)parameters completionBlock:(CompletionBlock)completionBlock urlString:(NSString*)urlString {
    
    return [self.sessionManager DELETE:urlString
                            parameters:parameters
                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                   [self connectionSuccess:completionBlock responseObject:responseObject];
                                   
                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                   [self connectionFail:completionBlock task:task error:error];
                               }];
}

@end
