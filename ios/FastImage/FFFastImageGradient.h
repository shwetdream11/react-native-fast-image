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

@interface FFFastImageGradient : NSObject

@property (nonatomic, assign) CGBlendMode blendMode;
@property (nonatomic, copy) NSArray<UIColor *>* colors;
@property (nonatomic, copy) NSArray* locations;
@property (nonatomic, copy) NSNumber* angle;

- (instancetype)initWithColors:(NSArray<UIColor *>*)colors
                     blendMode:(CGBlendMode)blendMode
                     locations:(NSArray *)locations
                         angle:(NSNumber *)angle;
@end

NS_ASSUME_NONNULL_END
