//
//  Boss2Fleet.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Boss2Fleet.h"
#import "PongVaderScene.h"
#import "ADMBrain.h"
#import "ADMBrainSeg.h"
#import "ADMBrainTail.h"
#import "Utils.h"

@interface Boss2Fleet(Private)
-(void) makePhysical;
@end

@implementation Boss2Fleet

@synthesize brain;

- (id) initAtOrigin: (CGPoint) atorigin 
			withDir: (CGPoint) dir
			playing: (NSString *) scoretoplay
		 difficulty: (int) level 
{
	if ((self = [super init])) {
		origin = atorigin;
		score = [scoretoplay retain];
		PongVader *pv = [PongVader getInstance];
		CGPoint pos = origin;
			
		ADMBrain *invader;
		
		invader = (ADMBrain *) [pv addSpriteBody:[ADMBrain class] atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
		invader->bdir = CGNormalize(dir);
		invader->fleet = self;
		[invader.parent reorderChild:invader z:1];
		[invaders addObject:invader];
		
		brain = invader;
		[brain retain];

		invader.tail = [pv addSpriteBody:[ADMBrainTail class] atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
		[invaders addObject:invader.tail];
		
		for (int i=BRAIN_MAX_SEGS-1; i>=BRAIN_MAX_SEGS-2; i--) {
			ADMBrainSeg *seg = (ADMBrainSeg *) [pv addSpriteBody:[ADMBrainSegSmall class] atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
			invader->segs[(BRAIN_MAX_SEGS-1)-i] = seg;
			seg->head = invader;
			[invaders addObject:seg];
		}

		for (int i=BRAIN_MAX_SEGS-3; i>=0; i--) {
			ADMBrainSeg *seg = (ADMBrainSeg *) [pv addSpriteBody:[ADMBrainSeg class] atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
			seg->head = invader;
			invader->segs[(BRAIN_MAX_SEGS-1)-i] = seg;
			[invaders addObject:seg];
		}
		
		for (int i=0; i<=BRAIN_MAX_SEGS; i++) {
			invader->prevs[i] = pos;
		}
		
		[self makePhysical];		
	}
	return self;
}

- (void) dealloc {
	// all invaders created by a fleet are managed by PV
	[score release];
	[brain release];
	[super dealloc];
}

- (BOOL) shouldRespondToBeat:(NSUInteger)beat {
	if ([score length] == 0) return NO;
	return [score UTF8String][beat % [score length]] != 'x';
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time {	
	//printf("beat: %2d\n", beat);
	char dowhat = [score UTF8String][beat % [score length]];
	if (dowhat == 'm') {
		[self moveFleet];
	} else if (dowhat == 's') {
		if (shouldShoot) [self shoot];
	} else if (dowhat == 'b') {
		[self moveFleet];
		if (shouldShoot) [self shoot];
	}
	lastBeat = beat;
}

- (void) moveFleet {
}

- (void) shoot {
	[[invaders objectAtIndex:0] shoot];
}

/*
 - (void) moveFleet {
 if ([invaders count] == 0) return;
 
 if ((direction.x > 0) && ([self mostRight] >= (origin.x - 50 + maxWidth / 2.0))) {
 direction = ccp(-1, 0);
 }
 else if ((direction.x < 0) && ([self mostLeft] <= (origin.x + 50 - maxWidth / 2.0))) {
 direction = ccp(1, 0);
 }
 
 for (Invader *invader in self.invaders) {
 [invader moveWithDir:direction andDistance: 50];
 }
 }
 */
- (void) makePhysical {
	for (SpriteBody<Shooter> *invader in invaders) {
		[invader makeActive];
	}
}

- (void) pause {
	brain.paused = YES;
}



@end
