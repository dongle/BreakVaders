//
//  ShieldBossFleet.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/18/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fleet.h"
#import "ShieldBoss.h"

#define LINEFLEET_ANIM_TIME 0.1

@interface ShieldBossFleet : Fleet {
	ShieldBoss *_boss;
	int _direction;
}

- (id) init;

//- (void) tick:(ccTime)dt;
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time;
- (void) moveFleet;

@end
