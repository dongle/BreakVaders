//
//  Invader.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/29/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "Invader.h"
#import "PongVaderScene.h"
#import "BeatSequencer.h"

#define RADIANS( degrees ) ( degrees * M_PI / 180 )

@implementation Invader
@synthesize health = _health;
@synthesize promoted = _promoted;

- (void) createBodyInWorld: (b2World *) w {
	// Create invader body
	b2BodyDef invBodyDef;
	invBodyDef.type = b2_staticBody;
	invBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	invBodyDef.userData = self;
	b2Body *invBody = w->CreateBody(&invBodyDef);
	
	// Create block shape
	b2PolygonShape invShape;
	invShape.SetAsBox(self.baseScale*self.contentSize.width/PTM_RATIO/2,
					  self.baseScale*self.contentSize.height/PTM_RATIO/2);
	
	// Create shape definition and add to body
	b2FixtureDef invShapeDef;
	invShapeDef.shape = &invShape;
	invShapeDef.density = 10.0;
	invShapeDef.friction = 0.0;
	invShapeDef.restitution = 0.1f;
	invShapeDef.filter.categoryBits = COL_CAT_INVADER;
	invShapeDef.filter.maskBits = COL_CAT_BALL | COL_CAT_DYNVADER;
	invBody->CreateFixture(&invShapeDef);
	
	self.b2dBody = invBody;
	invBody->SetActive(FALSE);
}

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	int i = arc4random() % 3;
	Invader *invader;
	
	NSString *invType=nil;
	
	switch(i) {
		case 0: invType = @"invader1"; break;
		case 1:	invType = @"invader1"; break;
		case 2: invType = @"invader1"; break;
	}
	
	invader = [Invader spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_walk1.png", invType]];
	invader.position = p;
	invader.world = w;
	invader.health = 1;
	if (_IPAD) {
		invader.baseScale = 2.0;
	}
	else {
		invader.baseScale = 1.0;
	}

	

	NSMutableArray *animFrames = [NSMutableArray array];
	for (int i=1; i<=6; i++) {
		[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_walk%d.png", invType, i]]];
	}
//	invader.idle = [CCAnimation animationWithName:@"idle" delay:GAME_SPB/3.0f frames:animFrames];
//    invader.idle = [CCAnimation animationWithAnimationFrames:animFrames delayPerUnit:GAME_SPB/3.0f loops:0];
	
	if (w) [invader createBodyInWorld: w];
	
	return invader;
}

- (Ball *) ballWithDirection: (CGPoint) dir {
	CGPoint pos = ccp(self.position.x, self.position.y);
	Ball *newball = (Ball *) [Ball spriteBodyAt:pos withForce: dir inWorld:_world];
	return newball;
}

- (void) shoot {
	//int angle = 115 + arc4random() % 130;
	
	int angle = 125 + arc4random() % 100;
	
	if (arc4random() % 2 == 0) {
		angle +=180;
	}
	
	float magnitude;
	magnitude =[[PongVader getInstance] randBallMagnitude];
	
	CGPoint force = ccp(magnitude*sin(RADIANS(angle)), magnitude*cos(RADIANS(angle)) );
	
	Ball *newball = [self ballWithDirection:force ];
	[[PongVader getInstance] addChild:newball];
	[[PongVader getInstance].balls addObject:newball];
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
}

- (void) promote: (int) level {
	
}

- (void) makeActive {
	if (_b2dBody == nil) {
		if (_world == nil) _world = [PongVader getInstance].world;
		[self createBodyInWorld:_world];
	}
	_b2dBody->SetActive(TRUE);
}

- (void) moveWithDir: (CGPoint) direction andDistance: (int) dist {
	[self runAction:[CCMoveBy actionWithDuration:(1 * 60/[BeatSequencer getInstance].bpmin)
										position:ccp(direction.x*dist, direction.y*dist)]];	
}

- (void) moveWithPos: (CGPoint) position {
	[self runAction:[CCMoveTo actionWithDuration:(1 * 60/[BeatSequencer getInstance].bpmin)
										position:position]];
}

- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	if ([self isDead]) return NO;
	
	_health -= damage;
	
	[ball increaseCombo];
	
	if (ball.lastPlayer)	[self doHitScore:ball];
	
	if (_promoted && _health == 1) {
		[self removeArmor];	
	}
	
	if ([self isDead] && ball.lastPlayer) [self doDestroyedScore:ball];

	return ![ball isHot];
}

- (void) removeArmor {

}

- (void) doHitScore: (Ball *) ball {
	[ball.lastPlayer incScoreBy:SCORE_HITINVADER*ball.combo];
}

- (void) doDestroyedScore: (Ball *) ball {
	[ball.lastPlayer incScoreBy:SCORE_DESTROYENS*ball.combo];	
}

- (BOOL) isDead
{
	return _health <= 0;
}

- (BOOL) doesCount { return YES; }
- (BOOL) isBoss { return NO; }

- (void) reset {
	_health = 1;
	self.rotation = 0;
}

// - (void) dealloc {} // PV manages the deallocation of this spritebody

@end
