#import <React/RCTConvert.h>

@class FFFastImageSource;
@class FFFastImageGradient;

@interface RCTConvert (FFFastImage)

+ (FFFastImageSource *)FFFastImageSource:(id)json;

+ (FFFastImageGradient *)FFFastImageGradient:(id)json;

@end
