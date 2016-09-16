#import "NSData+PKCS12.h"

@implementation NSData (PKCS12)

+ (NSData*)dataWithPKCS12HexString:(NSString*)dataString {
  char const *chars = dataString.UTF8String;
  NSUInteger charCount = strlen(chars);
  if (charCount % 2 != 0) {
    return nil;
  }
  NSUInteger byteCount = charCount / 2;
  uint8_t *bytes = malloc(byteCount);
  for (int i = 0; i < byteCount; i++) {
    unsigned int value;
    sscanf(chars + i * 2, "%2x", &value);
    bytes[i] = value;
  }
  return [NSData dataWithBytesNoCopy:bytes length:byteCount freeWhenDone:YES];
}

@end
