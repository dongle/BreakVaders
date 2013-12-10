//
//  Rock.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/2/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "Rock.h"
#import "Ball.h"
#import "Invader.h"
#import "PongVaderScene.h"

@implementation Rock
- (void) createBodyInWorld: (b2World *) w {
	// Create invader body
	b2BodyDef invBodyDef;
	invBodyDef.type = b2_staticBody;
	invBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	invBodyDef.userData = self;
	b2Body *invBody = w->CreateBody(&invBodyDef);
	
	// Create block shape
	b2PolygonShape invShape;

//	int num = 4;
//	b2Vec2 verts[] = {
//		b2Vec2(31.0f / PTM_RATIO, 31.0f / PTM_RATIO),
//		b2Vec2(-31.0f / PTM_RATIO, 31.0f / PTM_RATIO),
//		b2Vec2(-31.0f / PTM_RATIO, -31.0f / PTM_RATIO),
//		b2Vec2(31.0f / PTM_RATIO, -31.0f / PTM_RATIO)
//	};
	
//	int num = 8;
//	b2Vec2 verts[] = {
//		b2Vec2(22.9f / PTM_RATIO, 31.2f / PTM_RATIO),
//		b2Vec2(-23.5f / PTM_RATIO, 31.0f / PTM_RATIO),
//		b2Vec2(-30.6f / PTM_RATIO, 25.6f / PTM_RATIO),
//		b2Vec2(-30.7f / PTM_RATIO, -23.7f / PTM_RATIO),
//		b2Vec2(-26.1f / PTM_RATIO, -30.9f / PTM_RATIO),
//		b2Vec2(23.7f / PTM_RATIO, -31.0f / PTM_RATIO),
//		b2Vec2(31.1f / PTM_RATIO, -24.1f / PTM_RATIO),
//		b2Vec2(30.9f / PTM_RATIO, 25.4f / PTM_RATIO)
//	};
	
	int num = 9;
	b2Vec2 verts[9];
	
	
	if (_IPAD) {
		verts[0] = b2Vec2(5.5f / PTM_RATIO, 30.9f / PTM_RATIO);
		verts[1] = b2Vec2(-14.3f / PTM_RATIO, 30.9f / PTM_RATIO);
		verts[2] = b2Vec2(-30.2f / PTM_RATIO, 17.0f / PTM_RATIO);
		verts[3] = b2Vec2(-30.4f / PTM_RATIO, -11.1f / PTM_RATIO);
		verts[4] = b2Vec2(-11.8f / PTM_RATIO, -30.4f / PTM_RATIO);
		verts[5] = b2Vec2(6.9f / PTM_RATIO, -30.8f / PTM_RATIO);
		verts[6] = b2Vec2(26.5f / PTM_RATIO, -20.2f / PTM_RATIO);
		verts[7] = b2Vec2(31.1f / PTM_RATIO, -9.7f / PTM_RATIO);
		verts[8] = b2Vec2(30.8f / PTM_RATIO, 18.0f / PTM_RATIO);
	}
	else {
		verts[0] = b2Vec2(2.7f / PTM_RATIO, 15.5f / PTM_RATIO);
		verts[1] = b2Vec2(-7.1f / PTM_RATIO, 15.5f / PTM_RATIO);
		verts[2] = b2Vec2(-15.1f / PTM_RATIO, 8.5f / PTM_RATIO);
		verts[3] = b2Vec2(-15.1f / PTM_RATIO, -5.5f / PTM_RATIO);
		verts[4] = b2Vec2(-5.5f / PTM_RATIO, -15.2f / PTM_RATIO);
		verts[5] = b2Vec2(3.5f / PTM_RATIO, -15.2f / PTM_RATIO);
		verts[6] = b2Vec2(13.2f / PTM_RATIO, -10.1f / PTM_RATIO);
		verts[7] = b2Vec2(15.5f / PTM_RATIO, -4.8f / PTM_RATIO);
		verts[8] = b2Vec2(15.4f / PTM_RATIO, 9.0f / PTM_RATIO);
	}
	




	invShape.Set(verts, num);
	
	// Create shape definition and add to body
	b2FixtureDef invShapeDef;
	invShapeDef.shape = &invShape;
	invShapeDef.density = 10.0;
	invShapeDef.friction = 0.0;
	invShapeDef.restitution = 0.1f;
	invShapeDef.filter.categoryBits = COL_CAT_WALL;
	invShapeDef.filter.maskBits = COL_CAT_BALL | COL_CAT_DYNVADER;
	invBody->CreateFixture(&invShapeDef);
	
	self.b2dBody = invBody;
	invBody->SetActive(FALSE);
}

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	Rock *rock;
	
	rock = [Rock spriteWithSpriteFrameName:@"asteroid1.png"];
	rock.position = p;
	rock.world = w;
	
	if (_IPAD) {
		rock.baseScale = 2.0;
	}
	else {
		rock.baseScale = 1.0;
	}
	
	
	if (w) [rock createBodyInWorld: w];
	
	[rock makeActive];
	
	return rock;
}

- (void) makeActive {
	if (_b2dBody == nil) {
		if (_world == nil) _world = [PongVader getInstance].world;
		[self createBodyInWorld:_world];
	}
	_b2dBody->SetActive(TRUE);
}

- (void) promote:(int)level {}
- (BOOL) doesCount { return NO;}
- (BOOL) isDead { return NO; }
- (BOOL) isBoss { return NO; }
- (BOOL) doHitFrom:(Ball *)player withDamage:(int) damage { return NO; }
- (void) shoot {}
- (Ball *) ballWithDirection: (CGPoint) dir { return nil;}
- (void) doDestroyedScore:(Ball *) player {}
- (void) doHitScore:(Ball *) player {}
- (void) moveWithDir: (CGPoint) dir andDistance: (int) dist {}
@end
