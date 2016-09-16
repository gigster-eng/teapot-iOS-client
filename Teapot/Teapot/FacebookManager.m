#import "FacebookManager.h"

#define kFacebookCompletionGesturePost @"post"
#define kFacebookCompletionGestureCancel @"cancel"

typedef void(^FBLoginCompletion)(BOOL success);

@implementation FacebookManager

+ (FacebookManager *)defaultManager {
    static dispatch_once_t pred = 0;
    static FacebookManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[FacebookManager alloc] init];
    });
    return shared;
}

#pragma mark - public methods

- (void)getReadSessionToken:(FBAccessTokenCompletion)completion {
    [self getSessionToken:completion forPublish:NO tryLogin:YES];
}

- (void)getPublishSessionToken:(FBAccessTokenCompletion)completion {
    [self getSessionToken:completion forPublish:YES tryLogin:YES];
}

- (void)getLoggedUserInfo:(FBRequestCallback)callback {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email" forKey:@"fields"];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                  id result, NSError *error) {
         callback(result,error);
     }];
}

- (void)getLoggedUserProfilePhotoURL:(FBUserPhotoURLCompletion)completion {
    [self facebookRequest:@"me" visibleLogin:NO completion:^(NSDictionary *result) {
        if (result && result[@"username"]) {
            NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", result[@"username"]];
            if (completion) completion(url);
        } else {
            if (completion) completion(nil);
        }
    }];
}

- (void)getFriends:(FBRequestBlock)completion {
    NSString *query = @"me/friends?fields=name,email,picture,first_name,last_name";
    [self facebookRequest:query visibleLogin:YES completion:completion];
}

#pragma mark - private methods

- (void)getSessionToken:(FBAccessTokenCompletion)completion forPublish:(BOOL)forPublish tryLogin:(BOOL)tryLogin {
    if (!completion) { return; }
    
    FBSDKAccessToken *currentToken = [FBSDKAccessToken currentAccessToken];
    
    if ([[currentToken refreshDate] daysUntil:[NSDate date]] > 1) {
        currentToken = nil;
    }
    
    // Try to use existing token for this purpose (for publish or read)
    if (forPublish) {
        if (currentToken && [currentToken hasGranted:@"publish_actions"]) {
            completion(currentToken);
            return;
        }
    } else {
        if (currentToken && [currentToken hasGranted:@"public_profile"]) {
            completion(currentToken);
            return;
        }
    }
    
    // Login and try one last time
    if (tryLogin) {
        NSLog(@"[FacebookManager] Starting new Facebook session.");
        [self login:^(BOOL success) {
            if (success) {
                [self getSessionToken:completion forPublish:forPublish tryLogin:NO];
            } else {
                NSLog(@"[FacebookManager] Could not start Facebook session.");
                completion(nil);
            }
        } forPublish:forPublish];
    
    } else {
        completion(nil);
    }
}

- (void)logout {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [login logOut];
    }
}

- (void)login:(FBLoginCompletion)completion forPublish:(BOOL)forPublish {
    if (!completion) { return; }

    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [login logOut];
    }
    
    FBSDKLoginManagerRequestTokenHandler handler = ^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"[FacebookManager] Login failed: %@", [FBSDKAccessToken currentAccessToken].tokenString);
            NSLog(@"[FacebookManager] Error: %@", error);
            [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
            completion(NO);
            
        } else if (result.isCancelled) {
            NSLog(@"[FacebookManager] Login canceled.");
            completion(NO);
            
        } else {
            NSLog(@"[FacebookManager] New session token: %@", [FBSDKAccessToken currentAccessToken].tokenString);
            completion(YES);
        }
    };
    
    if (forPublish) {
        NSArray *writePermissions = @[@"publish_actions"];
        [login logInWithPublishPermissions:writePermissions fromViewController:nil handler:handler];
    } else {
        NSArray *readPermissions = @[@"public_profile",
                                     @"user_friends",
                                     @"email"];
        
        [login logInWithReadPermissions:readPermissions fromViewController:nil handler:handler];
    }
    
}

- (void)facebookRequest:(NSString *)query visibleLogin:(BOOL)visibleLogin completion:(FBRequestBlock)completion {
    if (!completion) { return; }

    [self getReadSessionToken:^(FBSDKAccessToken *token) {
        if (token) {
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:query parameters:nil];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error) {
                    NSLog(@"[FacebookManager] An error occurred while executing request %@: %@", query, error);
                    completion(nil);
                } else {
                    completion(result);
                }
            }];
            
        } else {
            completion(nil);
        }
    }];
}

@end
