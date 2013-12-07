//
//  PixelLabel.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PixelLabel.h"


@implementation PixelLabel

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super initWithCoder: decoder])) {
        [self setFont: [UIFont fontWithName: @"solvalou_combat_aircraft__solid.ttf" size: self.font.pointSize]];
    }
    
    return self;
}

@end
