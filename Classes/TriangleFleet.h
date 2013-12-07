//
//  TriangleFleet.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/30/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fleet.h"

#define LINEFLEET_ANIM_TIME 0.1
#define LINEFLEET_START_SIZE 5

@interface TriangleFleet : Fleet {

}

- (id) initWithSize:(int) rows atPos:(CGPoint) pos withSpacing:(int) spacing upsideDown:(BOOL) upsidedown sideways:(BOOL) sideways difficulty: (int) level;
- (void) moveFleet;

@end
