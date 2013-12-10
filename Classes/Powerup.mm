//
//  Powerup.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/4/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "Powerup.h"


@implementation Powerup

@synthesize state = _state;
@synthesize health = _health;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	// Create sprite and add it to the layer
	Powerup *pill = [Powerup spriteWithFile:@"redPill.png"];

	pill.position = p;
	pill.world = w;
	pill.health = 1;
	pill.state = 1;
	
	// Create ball body and add to ball SpriteBody
	b2BodyDef pillBodyDef;
	pillBodyDef.type = b2_dynamicBody;
	pillBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	pillBodyDef.userData = pill;
	b2Body *pillBody = w->CreateBody(&pillBodyDef);
	pill.b2dBody = pillBody;
	pillBody->SetFixedRotation(1);
	
	// Create circle shape
	b2PolygonShape pillShape;
	pillShape.SetAsBox(pill.contentSize.width/PTM_RATIO/2,
					   pill.contentSize.height/PTM_RATIO/2);
	
	// Create shape definition and add to body
	b2FixtureDef pillShapeDef;
	pillShapeDef.shape = &pillShape;
	pillShapeDef.density = 1.0f;
	pillShapeDef.friction = 0.0f;
	pillShapeDef.restitution = 1.0f;
	pillShapeDef.filter.categoryBits = COL_CAT_BALL;
	pillShapeDef.filter.maskBits = COL_CAT_PADDLE;
	pillBody->CreateFixture(&pillShapeDef);
	
	// Give shape initial impulse
	b2Vec2 force = b2Vec2(f.x, f.y);
	pill.b2dBody->ApplyLinearImpulse(force, pillBodyDef.position);
	
	return pill;
}

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withEffect: (int) e withForce: (CGPoint) f inWorld: (b2World *) w {
	// Create sprite and add it to the layer
	Powerup *pill=nil;
	
	switch (e) {
		case POW_ENSPRANCE:
			if (_IPAD) {
				pill = [Powerup spriteWithFile:@"bluePill.png"];
			}
			else {
				pill = [Powerup spriteWithFile:@"bluePill-low.png"];
			}
			
			break;
		case POW_LTWADDLE:
			if (_IPAD) {
				pill = [Powerup spriteWithFile:@"magPill.png"];
			}
			else {
				pill = [Powerup spriteWithFile:@"magPill-low.png"];
			}
			
			break;
		case POW_CDRBOBBLE:
			if (_IPAD) {
				pill = [Powerup spriteWithFile:@"greenPill.png"];
			}
			else {
				pill = [Powerup spriteWithFile:@"greenPill-low.png"];
			}
			
			break;
		case POW_STAT:
			if (_IPAD) {
				pill = [Powerup spriteWithFile:@"redPill.png"];
			}
			else {
				pill = [Powerup spriteWithFile:@"redPill-low.png"];
			}
			
			break;
		case POW_SHLD:
			pill = [Powerup spriteWithFile:@"yellowPill.png"];
			break;
		default:
			break;
	}
	
	pill.position = p;
	pill.world = w;
	pill.state = e;
	pill.health = 1;
	
	if (_IPAD) {
		//pill.scale = 2.0;
	}
	
	// Create ball body and add to ball SpriteBody
	b2BodyDef pillBodyDef;
	pillBodyDef.type = b2_dynamicBody;
	pillBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	pillBodyDef.userData = pill;
	b2Body *pillBody = w->CreateBody(&pillBodyDef);
	pill.b2dBody = pillBody;
	pillBody->SetFixedRotation(1);
	
	// Create circle shape
	b2PolygonShape pillShape;
	pillShape.SetAsBox((pill.scale*pill.contentSize.width)/PTM_RATIO/2,
					   (pill.scale*pill.contentSize.height)/PTM_RATIO/2);
	
	// Create shape definition and add to body
	b2FixtureDef pillShapeDef;
	pillShapeDef.shape = &pillShape;
	pillShapeDef.density = 1.0f;
	pillShapeDef.friction = 0.0f;
	pillShapeDef.restitution = 1.0f;
	pillShapeDef.filter.categoryBits = COL_CAT_BALL;
	pillShapeDef.filter.maskBits = COL_CAT_PADDLE;
	pillBody->CreateFixture(&pillShapeDef);
	
	// Give shape initial impulse
	b2Vec2 force = b2Vec2(f.x, f.y);
	pill.b2dBody->ApplyLinearImpulse(force, pillBodyDef.position);
		
	return pill;
}

- (BOOL) doKill {
	_health = 0;
	return YES;
}

- (BOOL) isDead
{
	return _health <= 0;
}

- (void) doHitFrom: (Ball *) ball withDamage: (int) d {
	return;
}

@end
