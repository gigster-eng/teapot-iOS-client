#import "UIFont+SystemFontOverride.h"

@implementation UIFont (SystemFontOverride)

+ (UIFont *)kitLightSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)kitBoldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont boldSystemFontOfSize:fontSize];
}

+ (UIFont *)kitSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize];
}

@end
