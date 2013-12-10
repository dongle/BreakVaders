//
//  TriangleFleet.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/30/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "TriangleFleet.h"
#import "PongVaderScene.h"
#import "StationaryInvader.h"


@interface TriangleFleet(Private)
-(void) makePhysical;
@end

@implementation TriangleFleet
- (id) initWithSize:(int) rows atPos:(CGPoint) pos withSpacing:(int) spacing upsideDown:(BOOL) upsidedown sideways:(BOOL) sideways difficulty: (int) level {
	if ((self = [super init])) {
//		CGSize screenSize = [CCDirector sharedDirector].winSize;
		PongVader *pv = [PongVader getInstance];
		
		for(int i = 0; i < rows; i++) {
			
			for (int j = 0; j < i; j++) {
				CGPoint position;
				if (!upsidedown) {	position = ccp(pos.x - (i*spacing) + (2*j*spacing), pos.y - (i*spacing)); }
				else {	position = ccp(pos.x - (i*spacing) + (2*j*spacing), pos.y + (i*spacing));		}
				
				StationaryInvader *invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -1300 : 1300 + position.x,  upsidedown ? -1300 : 1300 + position.y) withForce:ccp(0,0)];
				invader.scale = LINEFLEET_START_SIZE;
				if (i%2 == upsidedown) invader.rotation = 180;
				[_invaders addObject:invader];
				
				[invader runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCMoveTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) position:ccp(position.x, position.y)]]];
				[invader runAction:
				 [CCEaseExponentialOut actionWithAction:
				  [CCScaleTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) scale:1.0]]];
			}
		}
		[self performSelector:@selector(makePhysical) withObject:nil afterDelay:LINEFLEET_ANIM_TIME*rows];
	}
	return self;
}

- (void) moveFleet {
	
}

- (void) makePhysical {
	for (StationaryInvader *invader in _invaders) {
		[invader makeActive];
	}
}
@end
