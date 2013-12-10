//
//  ColumnFleet.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/30/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ColumnFleet.h"
#import "PongVaderScene.h"
#import "StationaryInvader.h"

@implementation ColumnFleet

- (id) initWithSize:(int) size andSpacing:(int) spacing atPos:(CGPoint) pos upsideDown:(BOOL) upsidedown stationary:(BOOL) stat difficulty: (int) level {
	if ((self = [super init])) {
//		CGSize screenSize = [CCDirector sharedDirector].winSize;
		PongVader *pv = [PongVader getInstance];

		for(int i = 0; i < size; i++) {
			StationaryInvader *invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(pos.x, upsidedown ? -300 : 1300 + i*spacing) withForce:ccp(0,0)];
			invader.scale = LINEFLEET_START_SIZE;
			if (i%2 == upsidedown) invader.rotation = 180;
			[_invaders addObject:invader];
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) position:ccp(pos.x, pos.y + i * spacing)]]];
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCScaleTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) scale:1.0]]];
		}
		[self performSelector:@selector(makePhysical) withObject:nil afterDelay:LINEFLEET_ANIM_TIME*size];   
		_stationary = stat;
	}
	return self;
}

// consider moving left and right only slightly (say, 60 px or spacing or something?)
// consider alternating dir with invaders so they zig zag, reform line, zig zag, etc
- (void) moveFleet {
	
}

- (void) makePhysical {
	for (StationaryInvader *invader in _invaders) {
		[invader makeActive];
	}
}

@end
