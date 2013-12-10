//
//  SNEye.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 1/21/11.
//  Copyright 2011 Koduco Games. All rights reserved.
//

#import "SNEye.h"
#import "BeatSequencer.h"
#import "PongVaderScene.h"
#import "Utils.h"

@implementation SNEye

@synthesize frozen = _frozen;
@synthesize shaking = _shaking;
@synthesize preShoot = _preShoot;
@synthesize eyeOpen = _eyeOpen;
@synthesize eyeClose = _eyeClose;
@synthesize deadEye = _deadEye;
@synthesize frozenTime = _frozenTime;
@synthesize fragment1 = _fragment1;
@synthesize fragment2 = _fragment2;
@synthesize fragment3 = _fragment3;
@synthesize fragment4 = _fragment4;
@synthesize flash = _flash;

- (void) createBodyInWorld: (b2World *) w {
	// Create invader body
	b2BodyDef invBodyDef;
	invBodyDef.type = b2_staticBody;
	invBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	invBodyDef.userData = self;
	b2Body *invBody = w->CreateBody(&invBodyDef);

	/*
	 full creature, needs to be doubled for phone or quadrupled for ipad
	b2Vec2 verts[] = {
		b2Vec2(-1.2f / PTM_RATIO, 31.2f / PTM_RATIO),
		b2Vec2(-15.0f / PTM_RATIO, -3.2f / PTM_RATIO),
		b2Vec2(0.0f / PTM_RATIO, -30.7f / PTM_RATIO),
		b2Vec2(15.0f / PTM_RATIO, -2.7f / PTM_RATIO)
	};
	 */
	
	/*
	 just the eye area, needs to be 2x for phn or 4x for pad
	 verts[0].Set(-0.6f / PTM_RATIO, 2.1f / PTM_RATIO);
	 verts[1].Set(-13.3f / PTM_RATIO, -3.5f / PTM_RATIO);
	 verts[2].Set(-0.3f / PTM_RATIO, -7.1f / PTM_RATIO);
	 verts[3].Set(12.8f / PTM_RATIO, -3.2f / PTM_RATIO);
	 */
	
	b2Vec2 vertsphn[] = {
		b2Vec2(-1.2f / PTM_RATIO, 4.2f / PTM_RATIO),
		b2Vec2(-26.6f / PTM_RATIO, -7.0f / PTM_RATIO),
		b2Vec2(-0.6f / PTM_RATIO, -14.0f / PTM_RATIO),
		b2Vec2(25.6f / PTM_RATIO, -6.4f / PTM_RATIO)
	};
	
	b2Vec2 vertspad[] = {
		b2Vec2(-2.4f / PTM_RATIO, 8.4f / PTM_RATIO),
		b2Vec2(-53.2f / PTM_RATIO, -14.0f / PTM_RATIO),
		b2Vec2(-1.2f / PTM_RATIO, -28.0f / PTM_RATIO),
		b2Vec2(51.2f / PTM_RATIO, -12.8f / PTM_RATIO)
	};
	
	// Create block shape
	b2PolygonShape invShape;
	
	if (_IPAD) {
		invShape.Set(vertspad, 4);
	}
	else {
		invShape.Set(vertsphn, 4);
	}
	
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
	SNEye *invader;
	PongVader *pv = [PongVader getInstance];
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	invader = [SNEye spriteWithSpriteFrameName:@"boss2_5.png"];
	invader.position = p;
	if (_IPAD) {
		invader.baseScale = 4.0;	
	}
	else {
		invader.baseScale = 2.0;
	}
	
	invader.world = w;
	invader.health = EYE_MAX_HEALTH;
	
	NSMutableArray *animFrames = [NSMutableArray array];
	//NSMutableArray *idleFrames = [NSMutableArray array];
	NSMutableArray *closeFrames = [NSMutableArray array];
	NSMutableArray *dyingFrames = [NSMutableArray array];
	
	for (int i=EYE_NUM_FRAMES; i>=1; i--) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"boss2_%d.png", i]];
		[frame.texture setAliasTexParameters];
		[animFrames addObject:frame];		
	}
	//invader.eyeOpen = [CCAnimation animationWithName:@"eyeOpen" delay:GAME_SPB/3.0f frames:animFrames];
	//[invader addAnimation: [CCAnimation animationWithName:@"eyeOpen" delay:GAME_SPB/3.0f frames:animFrames]];
	
	invader.eyeOpen = [CCAnimation animationWithName:@"eyeOpen" delay:(((float) NUMSHOTS)/[BeatSequencer getInstance].bpmin) frames:animFrames];
	[invader addAnimation: [CCAnimation animationWithName:@"eyeOpen" delay:(((float) NUMSHOTS)/[BeatSequencer getInstance].bpmin) frames:animFrames]];
	
	for (int i=1; i<=EYE_NUM_FRAMES-1; i++) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"boss2_%d.png", i]];
		[frame.texture setAliasTexParameters];
		[closeFrames addObject:frame];		
	}
	invader.eyeClose = [CCAnimation animationWithName:@"eyeClose" delay:EYE_FREEZETIME * 10.0/ (float) (EYE_NUM_FRAMES-1) frames:closeFrames];
	
	for (int i=1; i<=4; i++) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"boss2_bigeye%d.png", i]];
		[frame.texture setAliasTexParameters];
		[dyingFrames addObject:frame];		
	}
	invader.deadEye = [CCAnimation animationWithName:@"deadEye" delay:GAME_SPB/3.0f frames:dyingFrames];
	
	//CCSpriteFrame *idleFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"boss2_5.png"];
	//[idleFrame.texture setAliasTexParameters];
	//[idleFrames addObject:idleFrame];	
	//invader.idle = [CCAnimation animationWithName:@"idle" delay:GAME_SPB/8.0f frames:idleFrames];
	
	if (w) [invader createBodyInWorld: w];
	
	invader.frozen = NO;
	invader.shaking = NO;
	invader.frozenTime = 0;
	
	// initialize fragments for death sequence
	invader.fragment1 = [CCSprite spriteWithSpriteFrameName:@"boss_fragment.png"];
	invader.fragment2 = [CCSprite spriteWithSpriteFrameName:@"boss_fragment.png"];
	invader.fragment3 = [CCSprite spriteWithSpriteFrameName:@"boss_fragment.png"];
	invader.fragment4 = [CCSprite spriteWithSpriteFrameName:@"boss_fragment.png"];
	
	invader.flash = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0) width: ssz.width height: ssz.height];
	
	[pv addChild: invader.flash z: 0];
	
	return invader;
}

- (void) tick: (ccTime) dt {
	if (_shaking) {
		b2Vec2 vec = _b2dBody->GetPosition();
		int deltaPos = arc4random() % 10;
		self.position = ccp(vec.x*PTM_RATIO + deltaPos, vec.y*PTM_RATIO + deltaPos);
		_shakeTime+=dt;
		_explosionTime += dt;
		
		if (_shakeTime > 1.5) {
			_shaking = NO;
			_shakeTime = 0;
			_explosionTime = 0;
			self.position = ccp(vec.x*PTM_RATIO, vec.y*PTM_RATIO);
		}
		
		if (_explosionTime > .3) {
			printf("boom \n");
			// spawn particles
			int xOffset, yOffset;
			xOffset = (arc4random() % (int) self.contentSize.width) - (self.contentSize.width/2);
			yOffset= (arc4random() % (int) self.contentSize.height) - (self.contentSize.height/2);
			
			[[PongVader getInstance] addParticleAt:ccp(self.position.x + xOffset, self.position.y + yOffset) particleType: PART_DYN];
			
			// reset explosionTime
			_explosionTime = 0;
		}
		
	} 
	else {
		[super tick:dt];
	}
	
	if (_frozen) {
		_frozenTime += dt;
		
		//printf("frozenTime: %f \n", frozenTime);
		
		if (_frozenTime > EYE_FREEZETIME) {
			[self unfreeze];
		}
	}
	
	/*
	if (![self isDead]) {
		self.health = 0;
		[self deathExplosion];
	}
	 */
}

- (void) startFreeze {
	[self runAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.eyeOpen restoreOriginalFrame:NO], [CCCallFunc actionWithTarget: self selector:@selector(freeze)], nil]];

}

- (void) freeze {
	// flash
	[self.flash runAction:[CCSequence actions:[CCFadeIn actionWithDuration:.1], [CCFadeOut actionWithDuration:.1], nil]];
	
	[PongVader getInstance].frozen = YES;
	self.frozen = YES;
	
	for (Ball *ball in [PongVader getInstance].balls) {
		if (arc4random() % 10 > 1) {
			[ball makeFireball];
		}
	}
	
	[self runAction:[CCAnimate actionWithAnimation:self.eyeClose restoreOriginalFrame:NO]];
}

- (void) unfreeze {
	[PongVader getInstance].frozen = NO;
	// [self runAction:[CCAnimate actionWithAnimation:self.eyeClose restoreOriginalFrame:NO]];
	self.frozen = NO;
	self.preShoot = NO;
	self.frozenTime = 0;
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"EyeUnfreeze.wav"];
	
	[self stopAllActions];
	[self setDisplayFrame: @"eyeOpen" index:0];
}

- (void) nowShoot: (NSNumber *) ang {
	if ([self isDead]) return;
	
	float magnitude =[[PongVader getInstance] randBallMagnitude];
	int angle = [ang intValue];
	CGPoint force;
	
	if (_IPAD) {
		force = ccp(1.4*magnitude*sin(RADIANS(angle)), 1.4*magnitude*cos(RADIANS(angle)) );
	}
	else {
		force = ccp(magnitude*sin(RADIANS(angle)), magnitude*cos(RADIANS(angle)) );
	}
	
	Ball *newball = [self ballWithDirection:force ];
	// if (arc4random() % 2 == 0) { [newball makeFireball]; }
	[[PongVader getInstance] addChild:newball];
	[[PongVader getInstance].balls addObject:newball];
	
	
	
	//[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
}

- (void) nowShootFire: (NSNumber *) ang {
	if ([self isDead]) return;
	
	float magnitude = [[PongVader getInstance] randBallMagnitude];
	if (_IPAD) {
		magnitude *= 1.5;
	}
	int angle = [ang intValue];
	CGPoint force = ccp(magnitude*sin(RADIANS(angle)), magnitude*cos(RADIANS(angle)) );
	CGPoint pos;
	
	if ([ang intValue] > 90) {
		pos = ccp(self.position.x, self.position.y - self.contentSize.height);
	}
	else {
		pos = ccp(self.position.x, self.position.y + self.contentSize.height);
	}
	
	//Ball *newball = [self ballWithDirection:force ];
	Ball *newball = (Ball *) [Ball spriteBodyAt:pos withForce: force inWorld:_world];
	
	
	[[PongVader getInstance] addChild:newball];
	[[PongVader getInstance].balls addObject:newball];
	
	[newball makeFireball];
	
	//[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
}


- (void) shoot {
	
	if (_frozen || _shaking || [self isDead]) { return; }
	
	_preShoot = YES;
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	self.position = ccp(ssz.width/2, ssz.height/2);
	
	for (unsigned int i=0; i<10; i++) {
		[self performSelector:@selector(nowShoot:) withObject:[NSNumber numberWithInt:(-45+i*(9))] afterDelay:i/[BeatSequencer getInstance].bpmin];
		[self performSelector:@selector(nowShoot:) withObject:[NSNumber numberWithInt:180+(-45+i*(9))] afterDelay:i/[BeatSequencer getInstance].bpmin];
		//[self performSelector:@selector(nowShoot:) withObject:[NSNumber numberWithInt:180] afterDelay:i/[BeatSequencer getInstance].bpmin];
	}
	
	// [self performSelector:@selector(startFreeze) withObject:nil afterDelay:(((float) NUMSHOTS * 4.5)/[BeatSequencer getInstance].bpmin)];
	[self startFreeze];
}




- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	if (!_frozen) {
		[ball doKill];
		return NO;
	}
	else {
		[super doHitFrom:ball withDamage:1];
		[[SimpleAudioEngine _sharedEngine] playEffect:@"EyeWail.wav"];
		if (![self isDead]) _shaking = YES;
		for (Ball *ball in [PongVader getInstance].balls) {
			[ball doKill];
		}
		[self unfreeze];
		
		if ([self isDead]) {
			[self deathExplosion];	
		}
		
		return YES;
	}
}

- (void) moveWithDir: (CGPoint) direction andDistance: (int) dist {
	
	if (_frozen || _shaking || [self isDead]) {
		return;	
	}
	
	// move
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// deltas from the buffer - kind of incorrect usage of delta i guess
	int dX, dY;
	CGPoint newPos;
	
	if (_IPAD) {
		dX = arc4random() % ((int) ssz.width - (2 * EYE_BUFFERX_PAD));
		dY = arc4random() % ((int) ssz.height - (2 * EYE_BUFFERY_PAD));
		
		if (_preShoot) {
			// used to be self.position
			newPos = ccp(EYE_BUFFERX_PAD + dX, ssz.height/2);
		}
		else {
			newPos = ccp(EYE_BUFFERX_PAD + dX, EYE_BUFFERY_PAD + dY);
		}
	}
	else {
		dX = arc4random() % ((int) ssz.width - (2 * EYE_BUFFERX_PHN));
		dY = arc4random() % ((int) ssz.height - (2 * EYE_BUFFERY_PHN));
		
		if (_preShoot) {
			newPos = ccp(EYE_BUFFERX_PHN + dX, ssz.height/2);
		}
		else {
			newPos = ccp(EYE_BUFFERX_PHN + dX, EYE_BUFFERY_PHN + dY);
		}
	}
	
	[self runAction:[CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:.2 position:newPos] rate:2]];
	
	
	if ((arc4random() % 5) < 2) {
	// shoot
	[self nowShootFire:[NSNumber numberWithInt:(-45 + (arc4random() % 90))]];
	[self nowShootFire:[NSNumber numberWithInt:(135 + (arc4random() % 90))]];
	}
}

-(BOOL) isBoss {return YES;}

- (void) deathExplosion {
	[[SimpleAudioEngine sharedEngine] playEffect:@"EyeHurt.wav"];
	// animate eye closing
	[self runAction:[CCAnimate actionWithAnimation:self.deadEye restoreOriginalFrame:NO]];
	
	// scale and fade eye
	[self runAction:[CCFadeOut actionWithDuration:3.0]];
	[self runAction:[CCScaleTo actionWithDuration:3.0 scale: .05]];
	
	int xOffset = _fragment1.contentSize.width;
	int yOffset = _fragment1.contentSize.height;
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	// position and rotate and scale the fragments
	// upper left
	_fragment1.position = ccp(self.position.x-xOffset, self.position.y+yOffset);
	_fragment1.scale = 2.0;
	
	// lower right
	_fragment2.position = ccp(self.position.x+xOffset, self.position.y-yOffset);
	_fragment2.scale = 2.0;
	_fragment2.rotation = 180;
	
	
	// upper right
	_fragment3.position = ccp(self.position.x+xOffset, self.position.y+yOffset);
	_fragment3.scaleX = -2.0;
	_fragment3.scaleY = 2.0;
	
	// lower left
	_fragment4.position = ccp(self.position.x-xOffset, self.position.y-yOffset);
	_fragment4.scaleY = -2.0;
	_fragment4.scaleX = 2.0;
	
	
	// add fragments to pv scene
	[[PongVader getInstance] addChild: _fragment1];
	[[PongVader getInstance] addChild: _fragment2];
	[[PongVader getInstance] addChild: _fragment3];
	[[PongVader getInstance] addChild: _fragment4];
	
	// move and rotate actions on fragments
	[_fragment1 runAction:[CCMoveTo actionWithDuration:2.0 position:ccp(-100, ssz.height+100)]];
	[_fragment2 runAction:[CCMoveTo actionWithDuration:2.0 position:ccp(ssz.width+100, -100)]];
	[_fragment3 runAction:[CCMoveTo actionWithDuration:2.0 position:ccp(ssz.width+100, ssz.height+100)]];
	[_fragment4 runAction:[CCMoveTo actionWithDuration:2.0 position:ccp(-100, -100)]];
	
	[_fragment1 runAction:[CCRotateBy actionWithDuration:2.5 angle:720]];
	[_fragment2 runAction:[CCRotateBy actionWithDuration:2.5 angle:720]];
	[_fragment3 runAction:[CCRotateBy actionWithDuration:2.5 angle:720]];
	[_fragment4 runAction:[CCRotateBy actionWithDuration:2.5 angle:720]];
}

- (void) reset {
	_health = EYE_MAX_HEALTH;
	_b2dBody->SetTransform(_b2dBody->GetPosition(), 0);
	_frozen = NO;
	_shaking = NO;
	_shakeTime = 0;
	_explosionTime = 0;
	_frozenTime = 0;
}

- (void) dealloc {
	PongVader *pv = [PongVader getInstance];
	[pv removeChild:_fragment1 cleanup:YES];
	[pv removeChild:_fragment2 cleanup:YES];
	[pv removeChild:_fragment3 cleanup:YES];
	[pv removeChild:_fragment4 cleanup:YES];
	
	[_fragment1 release];
	[_fragment2 release];
	[_fragment3 release];
	[_fragment4 release];
	
	[pv removeChild:_flash cleanup:YES];
	[_flash release];
	
	[_eyeOpen release];
	[_eyeClose release];
	[_deadEye release];
	
	[super dealloc];
}

@end
