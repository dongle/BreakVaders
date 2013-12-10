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

@synthesize brain = _brain;

- (id) initAtOrigin: (CGPoint) atorigin 
			withDir: (CGPoint) dir
			playing: (NSString *) scoretoplay
		 difficulty: (int) level 
{
	if ((self = [super init])) {
		_origin = atorigin;
		_score = [scoretoplay retain];
		PongVader *pv = [PongVader getInstance];
		CGPoint pos = _origin;
			
		ADMBrain *invader;
		
		invader = (ADMBrain *) [pv addSpriteBody:[ADMBrain class] atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
		invader->_bdir = CGNormalize(dir);
		invader->_fleet = self;
		[invader.parent reorderChild:invader z:1];
		[_invaders addObject:invader];
		
		_brain = invader;
		[_brain retain];

		invader.tail = [pv addSpriteBody:[ADMBrainTail class] atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
		[_invaders addObject:invader.tail];
		
		for (int i=BRAIN_MAX_SEGS-1; i>=BRAIN_MAX_SEGS-2; i--) {
			ADMBrainSeg *seg = (ADMBrainSeg *) [pv addSpriteBody:[ADMBrainSegSmall class] atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
			invader->_segs[(BRAIN_MAX_SEGS-1)-i] = seg;
			seg->_head = invader;
			[_invaders addObject:seg];
		}

		for (int i=BRAIN_MAX_SEGS-3; i>=0; i--) {
			ADMBrainSeg *seg = (ADMBrainSeg *) [pv addSpriteBody:[ADMBrainSeg class] atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
			seg->_head = invader;
			invader->_segs[(BRAIN_MAX_SEGS-1)-i] = seg;
			[_invaders addObject:seg];
		}
		
		for (int i=0; i<=BRAIN_MAX_SEGS; i++) {
			invader->_prevs[i] = pos;
		}
		
		[self makePhysical];		
	}
	return self;
}

- (void) dealloc {
	// all invaders created by a fleet are managed by PV
	[_score release];
	[_brain release];
	[super dealloc];
}

- (BOOL) shouldRespondToBeat:(NSUInteger)beat {
	if ([_score length] == 0) return NO;
	return [_score UTF8String][beat % [_score length]] != 'x';
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time {	
	//printf("beat: %2d\n", beat);
	char dowhat = [_score UTF8String][beat % [_score length]];
	if (dowhat == 'm') {
		[self moveFleet];
	} else if (dowhat == 's') {
		if (_shouldShoot) [self shoot];
	} else if (dowhat == 'b') {
		[self moveFleet];
		if (_shouldShoot) [self shoot];
	}
	self->_lastBeat = beat;
}

- (void) moveFleet {
}

- (void) shoot {
	[[_invaders objectAtIndex:0] shoot];
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
	for (SpriteBody<Shooter> *invader in _invaders) {
		[invader makeActive];
	}
}

- (void) pause {
	_brain.paused = YES;
}



@end
