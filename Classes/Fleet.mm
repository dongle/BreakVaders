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

@synthesize invaders, lastShot, lastMovement, shouldShoot, numNukes;

- (id) init { 
	if ((self = [super init])) {
		lastShot = 0;
		lastMovement = 0;
		invaders = [[NSMutableArray alloc] init];
		shouldShoot = YES;
	}
	return self;
}

- (void) dealloc {
	[invaders release];
	[super dealloc];
}

- (BOOL) shouldRespondToBeat:(NSUInteger)beat { return (beat % 4) == 0;}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time {
	[self moveFleet];
	if (shouldShoot) [self shoot];
	lastBeat = beat;
}


-(void) tick: (ccTime)dt {
	
	lastShot += dt;
	lastMovement += dt;
	
	if (lastMovement >= TIMETOMOVE) {
		
		[self moveFleet];
		lastMovement = 0;
	}

	if (lastShot >= TIMETOSHOOT) {
		
		[self shoot];
		lastShot = 0;
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
	if ([invaders count]==0) return;
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
	for (Invader *i in invaders) {
		if ([i doesCount] && ![i isDead]) return NO;
	}
	return YES;
}

- (NSMutableArray *) getInvadersThatCount {
	NSMutableArray *invadersShoot = [NSMutableArray array];
	
	for (Invader *i in invaders) {
		if ([i doesCount] && ![i isDead]) {
			[invadersShoot addObject:i];	
		}
	}
	
	return invadersShoot;
}

- (void) removeInvader: (SpriteBody<Shooter> *) inv {
	[invaders removeObject:inv];

	
	
	// remove from nukes array
	for (int i=0; i<numNukes; i++) {
		if (nukes[i] == inv) {
			nukes[i] = nil;
		}
	}
}

- (DynamicInvader**) nukes {
	return (DynamicInvader**) nukes;
}

- (CGPoint*) nukepos {
	return (CGPoint*) nukepos;
}

- (void) designateAsNuke: (DynamicInvader *) nuke at:(CGPoint) pos {
	if (numNukes==MAX_NUKES) return;
	nukes[numNukes] = nuke;
	nukepos[numNukes] = pos;
	numNukes++;
	NSLog(@"%d nukes", numNukes);
}

- (BOOL) vacantNuke { 
	for (int i=0; i<numNukes; i++) {
		if (nukes[i] == nil) return YES;
	}
	return NO;
}


- (CGPoint) vacantNukePos 
// HACK: should be called before replaceNuke
// otherwise it will return nothing
{
	for (int i=0; i<numNukes; i++) {
		if (nukes[i] == nil) return nukepos[i];
	}
	return ccp(0,0);
}

- (void) replaceNuke: (DynamicInvader *) nuke 
// HACK: this function expects that the nuke passed in will be placed 
// at the same coordinates as what would be returned by vacantNukePos
// so nothing is done to ensure nukes[] and nukepos[] stay in sync
{
	for (int i=0; i<numNukes; i++) {
		if (nukes[i] == nil) { 
			nukes[i] = nuke;
			[invaders addObject:nuke];
			break;
		}
	}
}

@end
