#ifndef hole19_ConnectionURLS_h
#define hole19_ConnectionURLS_h

#define kServerURL(server, action) [NSString stringWithFormat: server, action]

// API
#define kAppwsServerURL @"https://api.teapot.co/%@"

#define kLoginProviders          kServerURL(kAppwsServerURL, @"teapot_app/preregistration/login_providers")
#define kUserRegister            kServerURL(kAppwsServerURL, @"v2/user/reg")
#define kUserProfile             kServerURL(kAppwsServerURL, @"teapot_app/user_profiles/profile/")

#define kFriendsList             kServerURL(kAppwsServerURL, @"teapot_app/user_profiles/friends")
#define kFriendsSearch           kServerURL(kAppwsServerURL, @"teapot_app/friends/search")

#define kGreeting                kServerURL(kAppwsServerURL, @"teapot_app/greetings/random")

#define kProductSearch           kServerURL(kAppwsServerURL, @"teapot_app/products/search")

#define kRecommendations         kServerURL(kAppwsServerURL, @"teapot_app/recommendations/recommend")

#define kListingCreate           kServerURL(kAppwsServerURL, @"teapot_app/listings/create")
#define kListingsFilter          kServerURL(kAppwsServerURL, @"teapot_app/listings/all")
#define kListingsSearch          kServerURL(kAppwsServerURL, @"teapot_app/listings/search")
#define kListingGet          kServerURL(kAppwsServerURL, @"teapot_app/listings/listing")

#define kMessageCreate           kServerURL(kAppwsServerURL, @"teapot_app/messages/create")
#define kMessageThreads          kServerURL(kAppwsServerURL, @"teapot_app/messages/all_threads")
#define kMessageThreadDetail     kServerURL(kAppwsServerURL, @"teapot_app/messages/thread")
#define kMessageMarkRead         kServerURL(kAppwsServerURL, @"teapot_app/messages/mark_as_read")

#define kSuggestions             kServerURL(kAppwsServerURL, @"teapot_app/suggestions")

#define kSettings                kServerURL(kAppwsServerURL, @"teapot_app/configuration/settings")
#endif
