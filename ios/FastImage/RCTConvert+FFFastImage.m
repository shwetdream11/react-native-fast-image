#import "RCTConvert+FFFastImage.h"
#import "FFFastImageSource.h"
#import "FFFastImageGradient.h"

@implementation RCTConvert (FFFastImage)

RCT_ENUM_CONVERTER(FFFPriority, (@{
                                   @"low": @(FFFPriorityLow),
                                   @"normal": @(FFFPriorityNormal),
                                   @"high": @(FFFPriorityHigh),
                                   }), FFFPriorityNormal, integerValue);

RCT_ENUM_CONVERTER(FFFCacheControl, (@{
                                       @"immutable": @(FFFCacheControlImmutable),
                                       @"web": @(FFFCacheControlWeb),
                                       @"cacheOnly": @(FFFCacheControlCacheOnly),
                                       }), FFFCacheControlImmutable, integerValue);

RCT_ENUM_CONVERTER(FFFastImageBlendMode, (@{
                                            @"overlay": @(FFFastImageBlendModeOverlay),
                                            }), FFFastImageBlendModeOverlay, integerValue);

+ (FFFastImageSource *)FFFastImageSource:(id)json {
    if (!json) {
        return nil;
    }
    
    NSString *uriString = json[@"uri"];
    NSURL *uri = [self NSURL:uriString];
    
    FFFPriority priority = [self FFFPriority:json[@"priority"]];
    FFFCacheControl cacheControl = [self FFFCacheControl:json[@"cache"]];
    
    NSDictionary *headers = [self NSDictionary:json[@"headers"]];
    if (headers) {
        __block BOOL allHeadersAreStrings = YES;
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, id header, BOOL *stop) {
            if (![header isKindOfClass:[NSString class]]) {
                RCTLogError(@"Values of HTTP headers passed must be  of type string. "
                            "Value of header '%@' is not a string.", key);
                allHeadersAreStrings = NO;
                *stop = YES;
            }
        }];
        if (!allHeadersAreStrings) {
            // Set headers to nil here to avoid crashing later.
            headers = nil;
        }
    }
    
    FFFastImageSource *imageSource = [[FFFastImageSource alloc] initWithURL:uri priority:priority headers:headers cacheControl:cacheControl];
    
    return imageSource;
}

+ (FFFastImageGradient *)FFFastImageGradient:(id)json {
    if (!json) {
        return nil;
    }
    
    FFFastImageBlendMode blendMode = [self FFFastImageBlendMode:json[@"blendMode"]];
    NSArray * gradientColors = json[@"colors"];
    NSArray * locations = json[@"locations"];
    
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:gradientColors.count];
    for (NSString *colorString in gradientColors)
    {
        if ([colorString isKindOfClass:UIColor.class])
        {
            [colors addObject:(UIColor *)colorString];
        }
        else
        {
            [colors addObject:[RCTConvert UIColor:colorString]];
        }
    }
    
    FFFastImageGradient * gradient = [[FFFastImageGradient alloc] initWithColors:colors blendMode:blendMode locations:locations];
    
    return gradient;
}

RCT_ARRAY_CONVERTER(FFFastImageSource);
RCT_ARRAY_CONVERTER(FFFastImageGradient);

@end
