//
//  XFleet.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/29/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "XFleet.h"
#import "PongVaderScene.h"
#import "StationaryInvader.h"

@interface XFleet(Private)
-(void) makePhysical;
@end

@implementation XFleet

- (id) initWithSize:(int) size andSpacing:(int) spacing atHeight:(int) height upsideDown:(BOOL) upsidedown stationary: (BOOL) stat difficulty: (int) level {
	if ((self = [super init])) {
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		PongVader *pv = [PongVader getInstance];
		
		//float left = screenSize.width / 2.0 - ((size-1)/4 +1)*spacing;
		float left = screenSize.width / 2.0;
		for(int i = 0; i < size; i++) {
			//StationaryInvader *invader;
			
			int row = (int) ((i-1)/4 + 1);
			CGPoint pos; // ccp(left + i * spacing, height)
			
			// first invader goes smack in the center
			if (i == 0) {
				//invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -300 : 1000, height) withForce:ccp(0,0)];
				pos = ccp(left + i * spacing, height);
			}
			
			// top right (+spacing, +spacing)
			else if (i % 4 == 0) {
				//invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -300 : 1000 + row*spacing, height +(row*spacing)) withForce:ccp(0,0)];
				pos = ccp(left + row*spacing, height +(row*spacing));
			}
			
			// bottom right (+spacing, -spacing)
			else if (i % 4 == 1) {
				//invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -300 : 1000 + row*spacing, height - (row*spacing)) withForce:ccp(0,0)];
				pos = ccp(left + row*spacing, height - (row*spacing));
			}
			
			// bottom left (-spacing, -spacing)
			else if (i % 4 == 2) {
				//invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -300 : 1000 - row*spacing, height - (row*spacing)) withForce:ccp(0,0)];
				pos = ccp(left - row*spacing, height - (row*spacing));
			}
			
			// top left (-spacing, +spacing)
			else if (i % 4 == 3) {
				//invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -300 : 1000 - row*spacing, height + (row*spacing)) withForce:ccp(0,0)];
				pos = ccp(left - row*spacing, height + (row*spacing));
			}
			
			SpriteBody<Shooter> *invader;
			
			if (stat) {
				invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -300 : 1000 + pos.x, pos.y) withForce:ccp(0,0)];	
			}
			else {
				int type = arc4random() % 4;
				
				switch (type) {
					case 0:
						invader = (ENSPrance *) [pv addSpriteBody:[ENSPrance class] atPos:ccp(upsidedown ? -300 : 1000 + pos.x, pos.y) withForce:ccp(0,0)];
						break;
					case 1:
						invader = (LTWaddle *) [pv addSpriteBody:[LTWaddle class] atPos:ccp(upsidedown ? -300 : 1000 + pos.x, pos.y) withForce:ccp(0,0)];
						break;
					case 2:
						invader = (CDRBobble *) [pv addSpriteBody:[CDRBobble class] atPos:ccp(upsidedown ? -300 : 1000 + pos.x, pos.y) withForce:ccp(0,0)];
						break;
					case 3:
						invader = (ShieldInvader *) [pv addSpriteBody:[ShieldInvader class] atPos:ccp(upsidedown ? -300 : 1000 + pos.x, pos.y) withForce:ccp(0,0)];
						break;
					default:
						break;
				}
			}
			
			int promote = arc4random() % 3;
			if (promote == 1) {
				[invader promote: level];
			}
			
			printf("i: %d row: %d\n", i, row);
			
			invader.scale = LINEFLEET_START_SIZE;
			if (i%2 == upsidedown) invader.rotation = 180;
			[_invaders addObject:invader];
			
			// move to final positions in an x
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) position:pos]]];
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCScaleTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) scale:1.0]]];
		}
		[self performSelector:@selector(makePhysical) withObject:nil afterDelay:LINEFLEET_ANIM_TIME*size];   
		_stationary = stat;
	}
	return self;
}


- (void) makePhysical {
	for (StationaryInvader *invader in _invaders) {
		[invader makeActive];
	}
}

- (void) moveFleet {}

@end
