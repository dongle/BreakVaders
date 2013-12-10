//
//  XFleet.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/29/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fleet.h"

#define LINEFLEET_ANIM_TIME 0.1
#define LINEFLEET_START_SIZE 5

@interface XFleet : Fleet {
	BOOL _stationary;
}

- (id) initWithSize:(int) size andSpacing:(int) spacing atHeight:(int) height upsideDown:(BOOL) upsidedown stationary:(BOOL) stat difficulty: (int) level;
- (void) moveFleet;

@end
