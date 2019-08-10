#import "FFFastImageView.h"

@interface UIImage (Tint)
- (UIImage *)tintedImageWithColor:(NSArray<UIColor *> *)colors blendingMode:(CGBlendMode)blendMode locations:(NSArray<NSNumber *>*)locations angle:(NSNumber *)angle;
@end

@implementation UIImage (Tint)

- (CGSize)calculateGradientLocationWithAngle:(CGFloat)angle
{
    CGFloat angleRad = (angle - 90) * (M_PI / 180);
    CGFloat length = sqrt(2);
    
    return CGSizeMake(cos(angleRad) * length, sin(angleRad) * length);
}

- (UIImage *)tintedImageWithColor:(NSArray<UIColor *> *)colors blendingMode:(CGBlendMode)blendMode locations:(NSArray<NSNumber *>*)locations angle:(NSNumber *)angle
{
    CGFloat *_locations = nil;
    
    _locations = malloc(sizeof(CGFloat) * colors.count);
    
    for (NSInteger i = 0; i < colors.count; i++) {
        if (locations.count > i) {
            _locations[i] = locations[i].floatValue;
        }
        else {
            _locations[i] = (1.0 / (colors.count - 1)) * i;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self drawInRect:bounds blendMode:kCGBlendModeNormal alpha:1.0f];
    CGContextSetBlendMode(ctx, blendMode);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *_colors = [NSMutableArray new];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_colors addObject:(__bridge id)obj.CGColor];
    }];
    CGGradientRef grad = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)_colors, _locations);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(1, 1);
    
    if ([angle floatValue] != 0.0) {
        CGPoint _angleCenter = CGPointMake(0.5, 0.5);
        CGSize size = [self calculateGradientLocationWithAngle: [angle floatValue]];
        startPoint.x = _angleCenter.x - size.width / 2;
        startPoint.y = _angleCenter.y - size.height / 2;
        endPoint.x = _angleCenter.x + size.width / 2;
        endPoint.y = _angleCenter.y + size.height / 2;
    }
    
    CGContextDrawLinearGradient(ctx,
                                grad,
                                CGPointMake(startPoint.x * bounds.size.width, startPoint.y * bounds.size.height),
                                CGPointMake(endPoint.x * bounds.size.width, endPoint.y * bounds.size.height),
                                0);
    CGGradientRelease(grad);
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@end



@implementation FFFastImageView {
    BOOL hasSentOnLoadStart;
    BOOL hasCompleted;
    BOOL hasErrored;
    NSDictionary* onLoadEvent;
}

- (id) init {
    self = [super init];
    self.resizeMode = RCTResizeModeCover;
    self.clipsToBounds = YES;
    return self;
}

- (void)setResizeMode:(RCTResizeMode)resizeMode
{
    if (_resizeMode != resizeMode) {
        _resizeMode = resizeMode;
        self.contentMode = (UIViewContentMode)resizeMode;
    }
}

- (void)setOnFastImageLoadEnd:(RCTBubblingEventBlock)onFastImageLoadEnd {
    _onFastImageLoadEnd = onFastImageLoadEnd;
    if (hasCompleted) {
        _onFastImageLoadEnd(@{});
    }
}

- (void)setOnFastImageLoad:(RCTBubblingEventBlock)onFastImageLoad {
    _onFastImageLoad = onFastImageLoad;
    if (hasCompleted) {
        _onFastImageLoad(onLoadEvent);
    }
}

- (void)setOnFastImageError:(RCTDirectEventBlock)onFastImageError {
    _onFastImageError = onFastImageError;
    if (hasErrored) {
        _onFastImageError(@{});
    }
}

- (void)setOnFastImageLoadStart:(RCTBubblingEventBlock)onFastImageLoadStart {
    if (_source && !hasSentOnLoadStart) {
        _onFastImageLoadStart = onFastImageLoadStart;
        onFastImageLoadStart(@{});
        hasSentOnLoadStart = YES;
    } else {
        _onFastImageLoadStart = onFastImageLoadStart;
        hasSentOnLoadStart = NO;
    }
}

- (void)sendOnLoad:(UIImage *)image {
    onLoadEvent = @{
                    @"width":[NSNumber numberWithDouble:image.size.width],
                    @"height":[NSNumber numberWithDouble:image.size.height]
                    };
    if (_onFastImageLoad) {
        _onFastImageLoad(onLoadEvent);
    }
}

- (void)setSource:(FFFastImageSource *)source {
    if (_source != source) {
        _source = source;
        
        // Load base64 images.
        NSString* url = [_source.url absoluteString];
        if (url && [url hasPrefix:@"data:image"]) {
            if (_onFastImageLoadStart) {
                _onFastImageLoadStart(@{});
                hasSentOnLoadStart = YES;
            } {
                hasSentOnLoadStart = NO;
            }
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_source.url]];
            [self setImage:image];
            if (_onFastImageProgress) {
                _onFastImageProgress(@{
                                       @"loaded": @(1),
                                       @"total": @(1)
                                       });
            }
            hasCompleted = YES;
            [self sendOnLoad:image];
            
            if (_onFastImageLoadEnd) {
                _onFastImageLoadEnd(@{});
            }
            return;
        }
        
        // Set headers.
        [_source.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString* header, BOOL *stop) {
            [[SDWebImageDownloader sharedDownloader] setValue:header forHTTPHeaderField:key];
        }];
        
        // Set priority.
        SDWebImageOptions options = 0;
        options |= SDWebImageRetryFailed;
        switch (_source.priority) {
            case FFFPriorityLow:
                options |= SDWebImageLowPriority;
                break;
            case FFFPriorityNormal:
                // Priority is normal by default.
                break;
            case FFFPriorityHigh:
                options |= SDWebImageHighPriority;
                break;
        }
        
        switch (_source.cacheControl) {
            case FFFCacheControlWeb:
                options |= SDWebImageRefreshCached;
                break;
            case FFFCacheControlCacheOnly:
                options |= SDWebImageCacheMemoryOnly;
                break;
            case FFFCacheControlImmutable:
                break;
        }
        
        if (_onFastImageLoadStart) {
            _onFastImageLoadStart(@{});
            hasSentOnLoadStart = YES;
        } {
            hasSentOnLoadStart = NO;
        }
        hasCompleted = NO;
        hasErrored = NO;
        
        // Load the new source.
        // This will work for:
        //   - https://
        //   - file:///var/containers/Bundle/Application/50953EA3-CDA8-4367-A595-DE863A012336/ReactNativeFastImageExample.app/assets/src/images/fields.jpg
        //   - file:///var/containers/Bundle/Application/545685CB-777E-4B07-A956-2D25043BC6EE/ReactNativeFastImageExample.app/assets/src/images/plankton.gif
        //   - file:///Users/dylan/Library/Developer/CoreSimulator/Devices/61DC182B-3E72-4A18-8908-8A947A63A67F/data/Containers/Data/Application/AFC2A0D2-A1E5-48C1-8447-C42DA9E5299D/Documents/images/E1F1D5FC-88DB-492F-AD33-B35A045D626A.jpg"
        [self sd_setImageWithURL:_source.url
                placeholderImage:nil
                         options:options
                        progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                            if (_onFastImageProgress) {
                                _onFastImageProgress(@{
                                                       @"loaded": @(receivedSize),
                                                       @"total": @(expectedSize)
                                                       });
                            }
                        } completed:^(UIImage * _Nullable image,
                                      NSError * _Nullable error,
                                      SDImageCacheType cacheType,
                                      NSURL * _Nullable imageURL) {
                            if (error) {
                                hasErrored = YES;
                                if (_onFastImageError) {
                                    _onFastImageError(@{});
                                }
                                if (_onFastImageLoadEnd) {
                                    _onFastImageLoadEnd(@{});
                                }
                            } else {
                                hasCompleted = YES;
                                [self sendOnLoad:image];
                                if (_onFastImageLoadEnd) {
                                    _onFastImageLoadEnd(@{});
                                }
                                [self updateGradient];
                            }
                        }];
    }
}

- (void)setGradient:(FFFastImageGradient *)gradient {
    if(_gradient != gradient) {
        _gradient = gradient;
        [self updateGradient];
    }
}

- (void)updateGradient {
    if (_gradient && [self image]) {
        [self setImage:[[self image] tintedImageWithColor:_gradient.colors blendingMode:_gradient.blendMode locations: _gradient.locations angle:_gradient.angle]];
    }
}

@end
