//
//  LineFleet.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LineFleet.h"
#import "PongVaderScene.h"
#import "Invader.h"
#import "ENSPrance.h"
#import "LTWaddle.h"
#import "CDRBobble.h"
#import "ShieldInvader.h"
#import "StationaryInvader.h"

@interface LineFleet(Private)
-(void) makePhysical;
@end

@implementation LineFleet

- (id) initWithSize:(int) size 
		   andWidth:(int) width 
		   maxWidth:(int) maxwidth 
		   atOrigin:(CGPoint) atorigin 
		 upsideDown:(BOOL) upsidedown 
		 stationary:(BOOL) stat 
		 difficulty:(int) level 
			classes:(Class *) classes 
{
	if ((self = [super init])) {
		maxWidth = maxwidth;
		origin = atorigin;
		direction = upsidedown ? ccp(-1, 0) : ccp(1, 0);
		PongVader *pv = [PongVader getInstance];
		float spacing = (size > 1) ? width / ((float) size-1) : 0;
		float left = origin.x - width/2.0f;
		//float left = screenSize.width / 2.0 - (size-1) * spacing / 2.0;
		for(int i = 0; i < size; i++) {
			SpriteBody<Shooter> *invader;
			
			if (stat) {
				invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -300 : 1000 + i*spacing, origin.y) withForce:ccp(0,0)];	
			}
			else {
				invader = [pv addSpriteBody:classes[i] atPos:ccp(upsidedown ? -300 : 1000 + i*spacing, origin.y) withForce:ccp(0,0)];
			}
			/*
			int promote = arc4random() % 3;
			if (promote == 1) {
				[invader promote: level];
			}
			 */
			invader.scale = LINEFLEET_START_SIZE;
			if (upsidedown) invader.rotation = 180;
			[invaders addObject:invader];
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) position:ccp(left + i * spacing, origin.y)]]];
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCScaleTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) scale:1.0]]];
		}
		[self performSelector:@selector(makePhysical) withObject:nil afterDelay:LINEFLEET_ANIM_TIME*size];   
	}
	return self;
}

- (void) dealloc {
	// all invaders created by a fleet are managed by PV
	[super dealloc];
}

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

- (void) makePhysical {
	for (Invader *invader in invaders) {
		[invader makeActive];
	}
}


@end
