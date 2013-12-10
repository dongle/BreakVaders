//
//  CircleFleet.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/30/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "CircleFleet.h"
#import "PongVaderScene.h"
#import "StationaryInvader.h"

#define RADIANS( degrees ) ( degrees * M_PI / 180 )

@implementation CircleFleet
- (id) initWithSize:(int) size andRadius:(int) rad atPos:(CGPoint) pos upsideDown:(BOOL) upsidedown stationary:(BOOL) stat difficulty: (int) level classes:(Class *) classes 
 {
	if ((self = [super init])) {
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		PongVader *pv = [PongVader getInstance];
		//float currentAngle = 0;
		float deltaAngle = 360/size;
		
		for(int i = 0; i < size; i++) {
			CGPoint position = ccp(pos.x + rad * sin(RADIANS(i*deltaAngle)), pos.y + rad * cos(RADIANS(i*deltaAngle)) );
			SpriteBody<Shooter> *invader;
			
			if (stat) {
				invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -1300 : 1300 + position.x,  upsidedown ? -1300 : 1300 + position.y) withForce:ccp(0,0)];	
			}
			else {
				invader = [pv addSpriteBody:classes[i] atPos:ccp(upsidedown ? -1300 : 1300 + position.x,  upsidedown ? -1300 : 1300 + position.y) withForce:ccp(0,0)];	
			}
			
			/*
			int promote = arc4random() % 3;
			if (promote == 1) {
				[invader promote: level];
			}
			*/
			
			//StationaryInvader *invader = (StationaryInvader *) [pv addSpriteBody:[StationaryInvader class] atPos:ccp(upsidedown ? -1300 : 1300 + position.x,  upsidedown ? -1300 : 1300 + position.y) withForce:ccp(0,0)];
			invader.scale = LINEFLEET_START_SIZE;
			if (i%2 == upsidedown) invader.rotation = 180;
			[_invaders addObject:invader];
			
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCMoveTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) position:ccp(position.x, position.y)]]];
			[invader runAction:
			 [CCEaseExponentialOut actionWithAction:
			  [CCScaleTo actionWithDuration:LINEFLEET_ANIM_TIME*(i+1) scale:1.0]]];
			
			_positions[i] = ccp(position.x, position.y);
		}
		[self performSelector:@selector(makePhysical) withObject:nil afterDelay:LINEFLEET_ANIM_TIME*size];
		
		// do stuff related to fleet size and movement
		_numInvaders = size;
		
		_positionOffset = 0;
		_currentInvaders = size;
		_currentOffset = 0;
	}
	return self;
}

- (void) moveFleet {
	NSMutableArray *tempInvaders = [[NSMutableArray alloc] init];
	
	for (Invader *invader in _invaders) {
		[tempInvaders addObject: invader];
	}
	
	_currentInvaders = [tempInvaders count];
	
	// message invaders to move to  points in array
	for (int i = 0; i < _currentInvaders; i++) {
		if ((_positionOffset + i + 1) > _numInvaders - 1) {
			_currentOffset = (_positionOffset + i + 1) % _numInvaders;
		}
		else { _currentOffset = _positionOffset + i + 1; }
		
		Invader *invader = (Invader *) [tempInvaders objectAtIndex:i];
		[invader moveWithPos: _positions[_currentOffset]];
		
		//printf("currentoffset: %d position.x: %f position.y: %f \n", currentOffset, positions[currentOffset].x, positions[currentOffset].y );
		
	}
	_positionOffset = (_positionOffset + _currentInvaders) % _numInvaders;
	//[[invaders objectAtIndex:(numInvaders -1)] moveWithPos: currentPositions[0]];
	printf("#invaders: %d \n", _currentInvaders);
	
	tempInvaders = nil;
}

- (void) makePhysical {
	for (StationaryInvader *invader in _invaders) {
		[invader makeActive];
	}
}
@end