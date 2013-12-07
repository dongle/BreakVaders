//
//  CircleFleet.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/30/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fleet.h"

#define LINEFLEET_ANIM_TIME 0.1
#define LINEFLEET_START_SIZE 5

@interface CircleFleet : Fleet {
	CGPoint positions[25];
	int positionOffset;
	int numInvaders;
	int currentInvaders;
	int currentOffset;
}

- (id) initWithSize:(int) size andRadius:(int) rad atPos:(CGPoint) pos upsideDown:(BOOL) upsidedown stationary:(BOOL) stat difficulty: (int) level classes:(Class *) classes;
- (void) moveFleet;

@end