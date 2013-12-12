//
//  DynamicInvader.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/21/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "DynamicInvader.h"
#import "PongVaderScene.h"
#define RADIANS( degrees ) ( degrees * M_PI / 180 )

@implementation DynamicInvader
@synthesize health = _health;
@synthesize lastBall = _lastBall;
@synthesize detonationTimer = _detonationTimer;

- (void) createBodyInWorld: (b2World *) w {
	// Create invader body
	b2BodyDef invBodyDef;
	invBodyDef.type = b2_dynamicBody;
	invBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	invBodyDef.userData = self;
	invBodyDef.fixedRotation = true;
	b2Body *invBody = w->CreateBody(&invBodyDef);
	
	// Create block shape
//	b2PolygonShape invShape;
//	invShape.SetAsBox(self.contentSize.width/PTM_RATIO/2,
//					  self.contentSize.height/PTM_RATIO/2);
	
	b2CircleShape invShape;
	invShape.m_radius = (float) (.5 * self.contentSize.width/PTM_RATIO);
	
	// Create shape definition and add to body
	b2FixtureDef invShapeDef;
	invShapeDef.shape = &invShape;
	invShapeDef.density = 1.0;
	invShapeDef.friction = 0.0;
	invShapeDef.restitution = 0.1f;
	invShapeDef.filter.categoryBits = COL_CAT_DYNVADER;
	invShapeDef.filter.maskBits = 0xFFFF;
	invBody->CreateFixture(&invShapeDef);
	
	self.b2dBody = invBody;
	
	invBody->SetActive(FALSE);
}

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	DynamicInvader *invader = [DynamicInvader spriteWithSpriteFrameName:@"dynamic_walk1.png"];
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
	for (int i=1; i<=4; i++) {
		[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"satellite%d.png", i]]];
	}
	invader.idle = [CCAnimation animationWithSpriteFrames:animFrames delay:GAME_SPB/3.0f];
	
	if (w) [invader createBodyInWorld: w];
	
	invader.detonationTimer = DYN_DETONATION;
	
	return invader;
}

- (void) dealloc {
	[_lastBall release];
	[super dealloc];
}

- (Ball *) ballWithDirection: (CGPoint) dir {
	CGPoint pos = ccp(self.position.x, self.position.y + dir.y*30);
	CGPoint force = ccp(dir.x, dir.y);
	return (Ball *) [Ball spriteBodyAt:pos withForce: force inWorld:_world];
}

- (void) shoot {
	
}

- (void) makeActive 
{
	if (_b2dBody == nil) {
		if (_world == nil) _world = [PongVader getInstance].world;
		[self createBodyInWorld:_world];
	}
	_b2dBody->SetTransform(b2Vec2(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO), 0);
	_b2dBody->SetActive(TRUE);
}

- (void) doKill {
	_health = 0;
}

- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	if ([self isDead]) return NO;
	
	[ball increaseCombo];
	
	//lastBall = ball; // this was the old way...

	// this is the new way: 
	// make a "ghost" of the last ball that keeps all that 
	// ball's personality but doesn't interact with the world.
	// This way the lastBall wont be destroyed before the dynInvader
	// explodes and needs to reference it. lastBall is released on dealloc
	_lastBall = [[Ball alloc] init];
	_lastBall.lastPlayer = ball.lastPlayer;
	_lastBall.health = ball.health;
	_lastBall.combo = ball.combo;
	_lastBall.volley = ball.volley;
	_lastBall.isNuke = YES;
	
	if (damage > 5) _health = 0;
	
	return NO; // DynamicInvaders don't hurt balls <- did you mean balls don't hurt DI?
}

- (void) doHitScore: (Ball *) ball {
	
}

- (void) doDestroyedScore: (Ball *) ball {
	
}

-(BOOL) isDead {
	return _health <= 0;
}

- (void) reset {
	_health = 1;
	b2Vec2 vel = b2Vec2(0,0);
	_b2dBody->SetLinearVelocity(vel);
	_detonationTimer = DYN_DETONATION;
}


- (void) promote:(int)level {
	
}


- (BOOL) doesCount {
	return NO;
}

- (BOOL) isBoss { return NO; }

- (void) moveWithDir: (CGPoint) p andDistance: (int) d {
	
}

-(void) tick: (ccTime)dt {
	[super tick:dt];
	
	b2Vec2 velocity = self.b2dBody->GetLinearVelocity();
	float minvelocity;
	
	if (_IPAD) {
		minvelocity = 1;
	}
	else {
		minvelocity = .12;
	}
	
	if (abs(velocity.y) < minvelocity) {
		self.b2dBody->SetLinearVelocity(b2Vec2(velocity.x, velocity.y*1.1));
	}
	
	_detonationTimer -= dt;
	
	if (_detonationTimer <= 0) {
		[self doKill];	
	}
}


@end
