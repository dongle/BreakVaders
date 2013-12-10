//
//  BlockFleet.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BlockFleet.h"

#import "PongVaderScene.h"
#import "Invader.h"
#import "ENSPrance.h"
#import "LTWaddle.h"
#import "CDRBobble.h"
#import "ShieldInvader.h"
#import "DynamicInvader.h"
#import "StationaryInvader.h"
#import "Rock.h"
#import "CPTDawdle.h"
#import "ADMBrain.h"
#import "SNEye.h"

Class char2class(char invType) {
	Class ret = 0;
	switch(invType) {
		case INV_RENU:
		case INV_PENU:
		case INV_REND:
		case INV_PEND: ret = [ENSPrance class]; break;
		case INV_RLTU:
		case INV_PLTU:
		case INV_RLTD:
		case INV_PLTD: ret = [LTWaddle class]; break;
		case INV_RCDU:
		case INV_PCDU:
		case INV_RCDD:
		case INV_PCDD: ret = [CDRBobble class]; break;
		case INV_RSTU:
		case INV_RSTD: ret = [StationaryInvader class]; break;
		case INV_RSHU:
		case INV_RSHD: ret = [ShieldInvader class]; break;
		case INV_RDYU:
		case INV_RDYD: ret = [DynamicInvader class]; break;
		case INV_RASU:
		case INV_RASD: ret = [Rock class]; break;
		case INV_RB1U:
		case INV_RB1D: ret = [CPTDawdle class]; break;
		case INV_RB2U:
		case INV_RB2D: ret = [ADMBrain class]; break;
		case INV_RB0U: ret = [SNEye class]; break;
	}
	return ret;
}

BOOL isInvUpsideDown(char invType) {
	return (invType == INV_REND) || (invType == INV_PEND) ||
	(invType == INV_RLTD) || (invType == INV_PLTD) ||
	(invType == INV_RCDD) || (invType == INV_PCDD) ||
	(invType == INV_RSTD) || (invType == INV_RSHD) ||
	(invType == INV_RDYD) || (invType == INV_RASD) ||
	(invType == INV_RB1D) || (invType == INV_RB2D);
}

BOOL isInvPromoted(char invType) {
	return (invType == INV_PENU) || (invType == INV_PEND) ||
	(invType == INV_PLTU) || (invType == INV_PLTD) ||
	(invType == INV_PCDU) || (invType == INV_PCDD);
}

BOOL shouldAnimateReveal(char invType) {
	return (invType != INV_RASD) && (invType != INV_RASU) && 
	(invType != INV_RDYD) && (invType != INV_RDYU) && 
	(invType != INV_RB2U) && (invType != INV_RB2D);
	
}

@interface BlockFleet(Private)
-(void) makePhysical;
@end


@implementation BlockFleet

- (id) initWithConfig: (char *) config
			  andDims: (CGPoint) dims 
		  withSpacing: (float) space
			 atOrigin: (CGPoint) atorigin 
			fromRight: (BOOL) fromright
			  playing: (NSString *) scoretoplay
		   difficulty: (int) level 
{
	if ((self = [super init])) {
		_dimensions = dims;
		_spacing = space;
		_origin = atorigin;
		_score = [scoretoplay retain];
		PongVader *pv = [PongVader getInstance];
		//float left = screenSize.width / 2.0 - (size-1) * spacing / 2.0;
		for(int i = 0; i < dims.x*dims.y; i++) {
			
			if (!char2class(config[i])) continue;
			
			CGPoint pos = ccp(atorigin.x - dims.x*space/2.0 + (i%(int)dims.x)*space + space / 2.0,
							  atorigin.y + dims.y*space/2.0 - (i/(int)dims.x)*space - space / 2.0);
			
			SpriteBody<Shooter> *invader;
			
			if (shouldAnimateReveal(config[i])) {
				invader = [pv addSpriteBody:char2class(config[i]) atPos:ccp(fromright ? -300 : 1000 + pos.x, pos.y) withForce:ccp(0,0)];
			}
			else {
				invader = [pv addSpriteBody:char2class(config[i]) atPos:ccp(pos.x, pos.y) withForce:ccp(0,0)];
			}

			if (isInvPromoted(config[i])) {
				[invader promote: level];
			}
			invader.scale = BLOCKFLEET_START_SIZE;
			if (isInvUpsideDown(config[i])) invader.rotation = 180;
			[_invaders addObject:invader];
			
			if (char2class(config[i]) == [DynamicInvader class]) {
				[self designateAsNuke: (DynamicInvader*)invader at:pos];
			}
			
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 position:pos]]];
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCScaleTo actionWithDuration:BLOCKFLEET_ANIM_TIME*5 scale:invader.baseScale]]];
		}
		[self performSelector:@selector(makePhysical) withObject:nil afterDelay:BLOCKFLEET_ANIM_TIME*5];   
	}
	return self;
}

- (void) dealloc {
	// all invaders created by a fleet are managed by PV
	[_score release];
	[super dealloc];
}

- (BOOL) shouldRespondToBeat:(NSUInteger)beat {
	if ([_score length] == 0) return NO;
	return [_score UTF8String][beat % [_score length]] != 'x';
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time {
	char dowhat = [_score UTF8String][beat % [_score length]];
	if (dowhat == 'm') {
		[self moveFleet];
	} else if (dowhat == 's') {
		if (_shouldShoot) [self shoot];
	} else if (dowhat == 'b') {
		[self moveFleet];
		if (_shouldShoot) [self shoot];
	}
	_lastBeat = beat;
}

- (void) moveFleet {
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


@end
