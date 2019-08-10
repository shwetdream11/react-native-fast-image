//
//  FFFastImageGradient.m
//  FastImage
//
//  Created by Shwet Solanki on 10/08/19.
//  Copyright © 2019 vovkasm. All rights reserved.
//

#import "FFFastImageGradient.h"

@implementation FFFastImageGradient

- (instancetype)initWithColors:(NSArray *)colors blendMode:(FFFastImageBlendMode)blendMode locations:(NSArray *)locations {
    self = [super init];
    if (self) {
        _colors = colors;
        _blendMode = blendMode;
        _locations = locations;
    }
    return self;
}

@end
