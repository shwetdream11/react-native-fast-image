//
//  FFFastImageGradient.m
//  FastImage
//
//  Created by Shwet Solanki on 10/08/19.
//  Copyright © 2019 vovkasm. All rights reserved.
//

#import "FFFastImageGradient.h"

@implementation FFFastImageGradient

- (instancetype)initWithColors:(NSArray *)colors blendMode:(CGBlendMode)blendMode locations:(NSArray *)locations angle:(nonnull NSNumber *)angle {
    self = [super init];
    if (self) {
        _colors = colors;
        _blendMode = blendMode;
        _locations = locations;
        _angle = angle;
    }
    return self;
}

@end
