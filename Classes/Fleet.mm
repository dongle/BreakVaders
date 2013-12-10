//
//  Fleet.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/29/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "Fleet.h"
#import "PongVaderScene.h"
#import "Shooter.h"

@implementation Fleet

@synthesize invaders = _invaders;
@synthesize lastShot = _lastShot;
@synthesize lastMovement = _lastMovement;
@synthesize shouldShoot = _shouldShoot;
//@synthesize nukes = _nukes;
//@synthesize nukepos = _nukepos;
@synthesize numNukes = _numNukes;

- (id) init { 
	if ((self = [super init])) {
		_lastShot = 0;
		_lastMovement = 0;
		_invaders = [[NSMutableArray alloc] init];
		_shouldShoot = YES;
	}
	return self;
}

- (void) dealloc {
	[_invaders release];
	[super dealloc];
}

- (BOOL) shouldRespondToBeat:(NSUInteger)beat { return (beat % 4) == 0;}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time {
	[self moveFleet];
	if (_shouldShoot) [self shoot];
	_lastBeat = beat;
}


-(void) tick: (ccTime)dt {
	
	_lastShot += dt;
	_lastMovement += dt;
	
	if (_lastMovement >= TIMETOMOVE) {
		
		[self moveFleet];
		_lastMovement = 0;
	}

	if (_lastShot >= TIMETOSHOOT) {
		
		[self shoot];
		_lastShot = 0;
	}
	
}

- (void) moveFleet {
	/*
	if ([invaders count] == 0) return;
	
	if ((direction > 0) && ([self mostRight] >= 704)) {
		direction = -1;
	}
	else if ((direction < 0) && ([self mostLeft] <= 64)) {
		direction = 1;
	}
	
	for (Invader *invader in self.invaders) {
		[invader moveWithDir:direction];
	}
	 */
}

- (void) shoot {
	if ([_invaders count]==0) return;
	//if ([[PongVader getInstance].balls count] >= [PongVader getInstance].numBalls) return;
	
	NSMutableArray *liveInvaders = [self getInvadersThatCount];

	if ([liveInvaders count] == 0) {
		return;	
	}
	
	SpriteBody<Shooter> *invader;
	
	// ensure shooting invader is on screen
//	int iteration = 0;
//	BOOL foundValid = false;
//	
//	
//	while (!foundValid) {
//		// choose an on-screen invader to shoot
//		int i = arc4random() % [liveInvaders count];
//		invader = [liveInvaders objectAtIndex:i];
//		
//		iteration++;
//		
//		if (invader.position.x <=1024 || iteration > 10) {
//			foundValid = true;
//		}
//	}
	
	int i = arc4random() % [liveInvaders count];
	invader = [liveInvaders objectAtIndex:i];
	
	[invader shoot];
}

// return position of mostLeft invader
- (int) mostLeft {
	int leftmost = 768;
	for (SpriteBody<Shooter> *invader in self.invaders) {
		if (invader.position.x < leftmost) {
			leftmost = invader.position.x;
		}
	}
	return leftmost;
}

// return position of mostRight invader
- (int) mostRight{
	int rightmost = 0;
	for (SpriteBody<Shooter> *invader in self.invaders) {
		if (invader.position.x > rightmost) {
			rightmost = invader.position.x;
		}
	}
	return rightmost;
}

// return position of mostLeft invader
- (int) lowest {
	int lowest = 1024;
	for (SpriteBody<Shooter> *invader in self.invaders) {
		if (invader.position.y < lowest) {
			lowest = invader.position.y;
		}
	}
	return lowest;
}

// return position of mostRight invader
- (int) highest {
	int highest = 0;
	for (SpriteBody<Shooter> *invader in self.invaders) {
		if (invader.position.y > highest) {
			highest = invader.position.y;
		}
	}
	return highest;
}


- (BOOL) isDead {
	for (Invader *i in _invaders) {
		if ([i doesCount] && ![i isDead]) return NO;
	}
	return YES;
}

- (NSMutableArray *) getInvadersThatCount {
	NSMutableArray *invadersShoot = [NSMutableArray array];
	
	for (Invader *i in _invaders) {
		if ([i doesCount] && ![i isDead]) {
			[invadersShoot addObject:i];	
		}
	}
	
	return invadersShoot;
}

- (void) removeInvader: (SpriteBody<Shooter> *) inv {
	[_invaders removeObject:inv];

	// remove from nukes array
	for (int i=0; i<_numNukes; i++) {
		if (_nukes[i] == inv) {
			_nukes[i] = nil;
		}
	}
}

- (DynamicInvader**) nukes {
	return (DynamicInvader**) _nukes;
}

- (CGPoint*) nukepos {
	return (CGPoint*) _nukepos;
}

- (void) designateAsNuke: (DynamicInvader *) nuke at:(CGPoint) pos {
	if (_numNukes==MAX_NUKES) return;
	_nukes[_numNukes] = nuke;
	_nukepos[_numNukes] = pos;
	_numNukes++;
	NSLog(@"%d nukes", _numNukes);
}

- (BOOL) vacantNuke { 
	for (int i=0; i<_numNukes; i++) {
		if (_nukes[i] == nil) return YES;
	}
	return NO;
}


- (CGPoint) vacantNukePos 
// HACK: should be called before replaceNuke
// otherwise it will return nothing
{
	for (int i=0; i<_numNukes; i++) {
		if (_nukes[i] == nil) return _nukepos[i];
	}
	return ccp(0,0);
}

- (void) replaceNuke: (DynamicInvader *) nuke 
// HACK: this function expects that the nuke passed in will be placed 
// at the same coordinates as what would be returned by vacantNukePos
// so nothing is done to ensure nukes[] and nukepos[] stay in sync
{
	for (int i=0; i<_numNukes; i++) {
		if (_nukes[i] == nil) {
			_nukes[i] = nuke;
			[_invaders addObject:nuke];
			break;
		}
	}
}

@end
