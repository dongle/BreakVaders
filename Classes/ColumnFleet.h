//
//  ColumnFleet.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/30/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fleet.h"

#define LINEFLEET_ANIM_TIME 0.1
#define LINEFLEET_START_SIZE 5

@interface ColumnFleet : Fleet {
	BOOL stationary;
}

- (id) initWithSize:(int) size andSpacing:(int) spacing atPos:(CGPoint) pos upsideDown:(BOOL) upsidedown stationary:(BOOL) stat difficulty: (int) level;
- (void) moveFleet;

@end
