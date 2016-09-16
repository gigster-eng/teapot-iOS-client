#import <Foundation/Foundation.h>

@interface NSData (PKCS12)

+ (NSData*)dataWithPKCS12HexString:(NSString*)dataString;

@end
