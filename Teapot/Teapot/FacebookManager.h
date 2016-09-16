#import <Foundation/Foundation.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "NSDate+Manager.h"

typedef void(^FBAccessTokenCompletion)(FBSDKAccessToken *token);
typedef void(^FBUserPhotoURLCompletion)(NSString *url);
typedef void(^FBRequestBlock)(NSDictionary *result);
typedef void(^FBRequestCallback)(NSDictionary *result, NSError* error);

@interface FacebookManager : NSObject

+ (FacebookManager *)defaultManager;

- (void)getReadSessionToken:(FBAccessTokenCompletion)completion;
- (void)getPublishSessionToken:(FBAccessTokenCompletion)completion;
- (void)getLoggedUserProfilePhotoURL:(FBUserPhotoURLCompletion)completionBlock;
- (void)getFriends:(FBRequestBlock)completionBlock;
- (void)getLoggedUserInfo:(FBRequestCallback)callback;
- (void)logout;

@end
