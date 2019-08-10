//
//  FFFastImageGradient.h
//  FastImage
//
//  Created by Shwet Solanki on 10/08/19.
//  Copyright © 2019 vovkasm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FFFastImageBlendMode) {
    FFFastImageBlendModeOverlay = kCGBlendModeOverlay
};

@interface FFFastImageGradient : NSObject

@property (nonatomic, assign) CGBlendMode blendMode;
@property (nonatomic, copy) NSArray<UIColor *>* colors;
@property (nonatomic, copy) NSArray* locations;

- (instancetype)initWithColors:(NSArray<UIColor *>*)colors
                     blendMode:(CGBlendMode)blendMode
                     locations:(NSArray *)locations;
@end

NS_ASSUME_NONNULL_END
