//
//  ShieldBoss.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/18/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ShieldBoss.h"


@implementation ShieldBoss

@synthesize shield = _shield;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	// make boss sprite
	ShieldBoss *shieldBoss = [ShieldBoss spriteWithFile:@"invader128.png"];
	shieldBoss.position = p;
	shieldBoss.world = w;
	shieldBoss.baseScale = 1.0;
	
	// make shield sprite and attach to boss
	shieldBoss.shield = [StaticSpriteBody spriteWithFile:@"shield64.png"];
	shieldBoss.shield.position = ccp(128 + shieldBoss.contentSize.width/2.0,128+shieldBoss.contentSize.height/2.0);
	[shieldBoss addChild:shieldBoss.shield];
	
	// make physical in world and return
	//if (w) [shieldBoss makePhysicalInWorld:w];
	return shieldBoss;
}

- (void) makePhysicalInWorld: (b2World *) w {
	if (!w) return;
	
	// Create invader body
	b2BodyDef invBodyDef;
	invBodyDef.type = b2_staticBody;
	invBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	invBodyDef.userData = self;
	b2Body *invBody = w->CreateBody(&invBodyDef);
	self.b2dBody = invBody;
	
	// Create block shape
	b2PolygonShape invShape;
	invShape.SetAsBox(self.contentSize.width/PTM_RATIO/2,
					  self.contentSize.height/PTM_RATIO/2);
	
	// Create shape definition and add to body
	b2FixtureDef invShapeDef;
	invShapeDef.shape = &invShape;
	invShapeDef.density = 10.0;
	invShapeDef.friction = 0.0;
	invShapeDef.restitution = 0.1f;
	invShapeDef.filter.categoryBits = COL_CAT_INVADER;
	invShapeDef.filter.maskBits = COL_CAT_BALL;
	invBody->CreateFixture(&invShapeDef);
	
	// DO IT AGAIN FOR THE SHIELD
	
	// Create shield body
	b2BodyDef shieldBodyDef;
	shieldBodyDef.type = b2_staticBody;
	shieldBodyDef.position.Set((self.position.x + _shield.position.x)/PTM_RATIO, (self.position.y + _shield.position.y)/PTM_RATIO);
	shieldBodyDef.userData = _shield;
	b2Body *shieldBody = w->CreateBody(&shieldBodyDef);
	_shield.b2dBody = shieldBody;
	
	// Create block shape
	b2PolygonShape shieldShape;
	shieldShape.SetAsBox(_shield.contentSize.width/PTM_RATIO/2,
					  _shield.contentSize.height/PTM_RATIO/2);
	
	// Create shape definition and add to body
	b2FixtureDef shieldShapeDef;
	shieldShapeDef.shape = &shieldShape;
	shieldShapeDef.density = 10.0;
	shieldShapeDef.friction = 0.0;
	shieldShapeDef.restitution = 0.1f;
	shieldShapeDef.filter.categoryBits = COL_CAT_INVADER;
	shieldShapeDef.filter.maskBits = COL_CAT_BALL;
	shieldBody->CreateFixture(&shieldShapeDef);
}

- (void) tick: (ccTime) dt {
	[super tick: dt];
	[_shield tick: dt];
}

@end
