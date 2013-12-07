//
//  DynamicLineFleet.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/21/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "DynamicLineFleet.h"
#import "PongVaderScene.h"
#import "DynamicInvader.h"

@interface DynamicLineFleet(Private)
-(void) makePhysical;
@end

@implementation DynamicLineFleet


- (id) initWithSize:(int) size andSpacing:(int) spacing atHeight:(int) height upsideDown:(BOOL) upsidedown difficulty: (int) level {
	if ((self = [super init])) {
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		PongVader *pv = [PongVader getInstance];
		//b2World *world = [PongVader getInstance].world;
		float left = screenSize.width / 2.0 - (size-1) * spacing / 2.0;
		for(int i = 0; i < size; i++) {
			//DynamicInvader *invader = (DynamicInvader *) [pv addSpriteBody:[DynamicInvader class] atPos:ccp(upsidedown ? -300 : 1000 + i*spacing, height) withForce:ccp(0,0)];
			DynamicInvader *invader = (DynamicInvader *) [pv addSpriteBody:[DynamicInvader class] atPos:ccp(left + i*spacing, height) withForce:ccp(0,0)];
//			invader.scale = LINEFLEET_START_SIZE;
			if (i%2 == upsidedown) invader.rotation = 180;
			[invaders addObject:invader];
//			[invader runAction:
//			 [CCEaseExponentialOut actionWithAction:
//			  [CCMoveTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) position:ccp(left + i * spacing, height)]]];
//			[invader runAction:
//			 [CCEaseExponentialOut actionWithAction:
//			  [CCScaleTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) scale:1.0]]];
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
	
}

- (void) makePhysical {
	for (DynamicInvader *invader in invaders) {
		[invader makeActive];
	}
}

@end
