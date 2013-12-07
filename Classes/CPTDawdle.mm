//
//  CPTDawdle.mm
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CPTDawdle.h"
#import "BeatSequencer.h"
#import "PongVaderScene.h"
#import "Utils.h"

static b2Vec2 __g_offsets[] = { 
	__g_offsets[0] = b2Vec2(0, (-69+69) / PTM_RATIO), //boss1_1.png 
	__g_offsets[1] = b2Vec2(0, (-58+69) / PTM_RATIO), //boss1_3.png 
	__g_offsets[2] = b2Vec2(0, (-53+69) / PTM_RATIO), //boss1_5.png 
	__g_offsets[3] = b2Vec2(0, (-49+69) / PTM_RATIO), //boss1_7.png 
	__g_offsets[4] = b2Vec2(0, (-53+69) / PTM_RATIO), //boss1_9.png 
	__g_offsets[5] = b2Vec2(0, (-53+69) / PTM_RATIO), //boss1_10.png 
	__g_offsets[6] = b2Vec2(0, (-61+69) / PTM_RATIO), //boss1_13.png 
	__g_offsets[7] = b2Vec2(0, (-65+69) / PTM_RATIO)}; //boss1_15.png 

static b2Vec2 __g_offsets_iphone[] = {
	__g_offsets_iphone[0] = b2Vec2(0, (-35+35) / PTM_RATIO), //boss1_1.png 
	__g_offsets_iphone[1] = b2Vec2(0, (-29+35) / PTM_RATIO), //boss1_3.png 
	__g_offsets_iphone[2] = b2Vec2(0, (-26.5f+35) / PTM_RATIO), //boss1_5.png 
	__g_offsets_iphone[3] = b2Vec2(0, (-24.5f+35) / PTM_RATIO), //boss1_7.png 
	__g_offsets_iphone[4] = b2Vec2(0, (-26.5f+35) / PTM_RATIO), //boss1_9.png 
	__g_offsets_iphone[5] = b2Vec2(0, (-26.5f+35) / PTM_RATIO), //boss1_10.png 
	__g_offsets_iphone[6] = b2Vec2(0, (-30.5f+35) / PTM_RATIO), //boss1_13.png 
	__g_offsets_iphone[7] = b2Vec2(0, (-32.5f+35) / PTM_RATIO)}; //boss1_15.png 


static b2Vec2 __g_verts[8];
b2Vec2 *getDVerts(int frame) {
	if (_IPAD) {
		__g_verts[0] = b2Vec2(127.2f / PTM_RATIO, -22.7f / PTM_RATIO) + __g_offsets[frame/2];
		__g_verts[1] = b2Vec2(102.0f / PTM_RATIO, 26.2f / PTM_RATIO) + __g_offsets[frame/2];
		__g_verts[2] = b2Vec2(56.0f / PTM_RATIO, 40.2f / PTM_RATIO) + __g_offsets[frame/2];
		__g_verts[3] = b2Vec2(-56.5f / PTM_RATIO, 40.5f / PTM_RATIO) + __g_offsets[frame/2];
		__g_verts[4] = b2Vec2(-102.0f / PTM_RATIO, 26.0f / PTM_RATIO) + __g_offsets[frame/2];
		__g_verts[5] = b2Vec2(-127.0f / PTM_RATIO, -22.0f / PTM_RATIO) + __g_offsets[frame/2];
		__g_verts[6] = b2Vec2(-20.0f / PTM_RATIO, -56.2f / PTM_RATIO) + __g_offsets[frame/2];
		__g_verts[7] = b2Vec2(20.0f / PTM_RATIO, -56.2f / PTM_RATIO) + __g_offsets[frame/2];
	}
	else {
		__g_verts[0] = b2Vec2(63.6f / PTM_RATIO, -11.3f / PTM_RATIO) + __g_offsets_iphone[frame/2];
		__g_verts[1] = b2Vec2(51.0f / PTM_RATIO, 13.1f / PTM_RATIO) + __g_offsets_iphone[frame/2];
		__g_verts[2] = b2Vec2(28.0f / PTM_RATIO, 20.1f / PTM_RATIO) + __g_offsets_iphone[frame/2];
		__g_verts[3] = b2Vec2(-28.2f / PTM_RATIO, 20.2f / PTM_RATIO) + __g_offsets_iphone[frame/2];
		__g_verts[4] = b2Vec2(-51.0f / PTM_RATIO, 13.0f / PTM_RATIO) + __g_offsets_iphone[frame/2];
		__g_verts[5] = b2Vec2(-63.5f / PTM_RATIO, -11.0f / PTM_RATIO) + __g_offsets_iphone[frame/2];
		__g_verts[6] = b2Vec2(-10.0f / PTM_RATIO, -28.1f / PTM_RATIO) + __g_offsets_iphone[frame/2];
		__g_verts[7] = b2Vec2(10.0f / PTM_RATIO, -28.1f / PTM_RATIO) + __g_offsets_iphone[frame/2];
	}
	
	return __g_verts;
}

@implementation CPTDawdle

- (void) createBodyInWorld: (b2World *) w {
	// Create invader body
	b2BodyDef invBodyDef;
	invBodyDef.type = b2_staticBody;
	invBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	invBodyDef.userData = self;
	b2Body *invBody = w->CreateBody(&invBodyDef);
	
	// Create block shape
	b2PolygonShape invShape;
	invShape.Set(getDVerts(0), 8);
	
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
	CPTDawdle *invader;
	
	invader = [CPTDawdle spriteWithSpriteFrameName:@"boss1_1.png"];
	invader.position = p;
	if (_IPAD) {
		invader.baseScale = 4.0;	
	}
	else {
		invader.baseScale = 2.0;
	}
	
	invader.world = w;
	invader.health = DAWDLE_MAX_HEALTH;
	
	NSMutableArray *animFrames = [NSMutableArray array];
	for (int i=1; i<=DAWDLE_NUM_FRAMES; i++) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"boss1_%d.png", i]];
		[frame.texture setAliasTexParameters];
		[animFrames addObject:frame];		
	}
	[invader addAnimation: [CCAnimation animationWithName:@"dawdle" delay:GAME_SPB/8.0f frames:animFrames]];
	invader->animTime = 0;
	
	if (w) [invader createBodyInWorld: w];

	
	return invader;
}

- (void) doRotate {
	if (upsidedown) {
		self.rotation = 0;
		b2dBody->SetTransform(b2dBody->GetPosition(), 0);
	} else {
		self.rotation = 180;
		b2dBody->SetTransform(b2dBody->GetPosition(), RADIANS(180));
	}
	upsidedown = !upsidedown;
}

-(void) tick: (ccTime)dt {
	if (shaking) {
		b2Vec2 vec = b2dBody->GetPosition();
		int deltaPos = arc4random() % 10;
		self.position = ccp(vec.x*PTM_RATIO + deltaPos, vec.y*PTM_RATIO + deltaPos);
		shakeTime+=dt;
		explosionTime += dt;
		
		if (shakeTime > 1.5) {
			shaking = NO;
			shakeTime = 0;
			explosionTime = 0;
			self.position = ccp(vec.x*PTM_RATIO, vec.y*PTM_RATIO);
			[self doRotate];
		}
		
		if (explosionTime > .3) {
			printf("boom \n");
			// spawn particles
			int xOffset, yOffset;
			xOffset = (arc4random() % (int) self.contentSize.width) - (self.contentSize.width/2);
			yOffset= (arc4random() % (int) self.contentSize.height) - (self.contentSize.height/2);
			
			[[PongVader getInstance] addParticleAt:ccp(self.position.x + xOffset, self.position.y + yOffset) particleType: PART_DYN];
		
			// reset explosionTime
			explosionTime = 0;
		}
		
	} else [super tick:dt];
	
	animTime += dt;
	float duration = 2 * 60/[BeatSequencer getInstance].bpmin;
	if (animTime > duration) animTime = 0;
	int frame = DAWDLE_NUM_FRAMES * animTime / duration;
	if (frame != lastFrame) {
	
		[self setDisplayFrame: @"dawdle" index:frame];

		if ((frame%4)==0) {
			b2Fixture *fixture = b2dBody->GetFixtureList();
			b2PolygonShape *shape = (b2PolygonShape*) fixture->GetShape();
			shape->Set(getDVerts(frame), 8);
		}
		lastFrame = frame;
	}
}

- (void) nowShoot: (NSNumber *) ang {
	if ([self isDead]) return;
	float magnitude =[[PongVader getInstance] randBallMagnitude];
	int angle = [ang intValue];
	CGPoint force = ccp(magnitude*sin(RADIANS(angle)), magnitude*cos(RADIANS(angle)) );
	
	Ball *newball = [self ballWithDirection:force ];
	[[PongVader getInstance] addChild:newball];
	[[PongVader getInstance].balls addObject:newball];
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
}

- (void) shoot {
	int angle = -45 + arc4random() % 90;
	if (upsidedown) angle +=180;
	[self nowShoot: [NSNumber numberWithInt:angle]];
	int speed = 2+arc4random()%3;
	
	for (unsigned int i=1; i<(4+arc4random()%4); i++) {
		[self performSelector:@selector(nowShoot:) withObject:[NSNumber numberWithInt:angle+i*10] afterDelay:i*(15*speed)/[BeatSequencer getInstance].bpmin];
	}
}

- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	//debug :
	if (ball == nil) {
		[super doHitFrom:ball withDamage:damage];
		return YES;
	}
	
	int bossHitOffset;
	
	if (_IPAD) {
		bossHitOffset = 25;	
	}
	else {
		bossHitOffset = 12;	
	}
	
	
	if ((!upsidedown && (ball.position.y > (self.position.y-bossHitOffset))) || 
		(upsidedown && (ball.position.y < (self.position.y+bossHitOffset)))) {
		
		if (_IPAD) {
			if ((!upsidedown && (self.position.y > 400)) || (upsidedown && (self.position.y < 624))) {
				
				[self runAction:[CCMoveBy actionWithDuration: 0.3
													position: upsidedown? ccp(0,25) : ccp(0,-25)]];	
			}
		}
		else {
			if ((!upsidedown && (self.position.y > 200)) || (upsidedown && (self.position.y < 312))) {
				
				[self runAction:[CCMoveBy actionWithDuration: 0.3
													position: upsidedown? ccp(0,12) : ccp(0,-12)]];	
			}
		}
		
		
		return ![ball isHot];
		
	} else if ([ball isHot]) { // underbelly
		[[SimpleAudioEngine sharedEngine] playEffect:@"DawdleWail.wav"];
		[super doHitFrom:ball withDamage:damage];
		if (![self isDead]) shaking = YES;
	}
	
//	id action1 = [CCPropertyAction actionWithDuration:0.1 key:@"RedTint" from:0 to:1];
//	id action2 = [CCPropertyAction actionWithDuration:0.1 key:@"RedTint" from:1 to:0];
//	id action3 = [CCPropertyAction actionWithDuration:0.1 key:@"RedTint" from:0 to:1];
//	CCRepeat *repeat_act = [CCRepeat actionWithAction:[CCSequence actions:action1, action2, action3, nil] times:3];
//	repeat_act.tag = ACTION_TAG_FLASHING;
//	[self runAction:repeat_act];
	
	return YES;
}

-(BOOL) isBoss {return YES;}

- (void) reset {
	health = DAWDLE_MAX_HEALTH;
	self.rotation = 0;
	b2dBody->SetTransform(b2dBody->GetPosition(), 0);
	upsidedown = NO;
}

@end
