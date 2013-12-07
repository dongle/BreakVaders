//
//  ShieldBossFleet.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/18/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ShieldBossFleet.h"
#import "PongVaderScene.h"

@implementation ShieldBossFleet

- (id) init {
	if ((self = [super init])) {
		direction = 0;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		PongVader *pv = [PongVader getInstance];
		
		boss = (ShieldBoss *) [pv addSpriteBody:[ShieldBoss class] atPos:ccp(1000, screenSize.height/2) withForce: ccp(0,0)];
		
		[invaders addObject:boss];
		
		[boss runAction:
		 [CCEaseExponentialOut actionWithAction:
		  [CCMoveTo actionWithDuration:LINEFLEET_ANIM_TIME position:ccp(screenSize.width/2, screenSize.height/2)]]];
//		[boss runAction:
//		 [CCEaseExponentialOut actionWithAction:
//		  [CCScaleTo actionWithDuration:LINEFLEET_ANIM_TIME scale:1.0]]];
		
		[self performSelector:@selector(makePhysical) withObject:nil afterDelay:LINEFLEET_ANIM_TIME];
	}

	return self;
}

- (BOOL) shouldRespondToBeat:(NSUInteger)beat { return (beat % 7) == 1;}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	[self moveFleet];
	[self shoot];
	lastBeat = beat;
}

//- (void) shoot {
//	
//}

- (void) moveFleet {
	if ([invaders count] == 0) return;
	
	if ((direction > 0) && ([self mostRight] >= (768 - 128))) {
		direction = -1;
	}
	else if ((direction < 0) && ([self mostLeft] <= (32 + .5*128))) {
		direction = 1;
	}
	
	for (ShieldBoss *aboss in self.invaders) {
		[aboss runAction:[CCMoveBy actionWithDuration:1
											   position:ccp(direction*64, 0)]];
	}
}

- (void) makePhysical {
	[boss makePhysicalInWorld:[PongVader getInstance].world];
}

@end