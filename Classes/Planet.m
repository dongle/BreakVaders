//
//  Planet.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Planet.h"
#import "SimpleAudioEngine.h"

@implementation Planet

@synthesize shaking = _shaking;
@synthesize health = _health;
@synthesize redTint = _redTint;

- (id) initAt: (CGPoint) p withRadius: (float) radius {
	if ((self = [super init])) {
		
		_health = 0;

		CCSprite *atmos;
		
		if (_IPAD) {
			atmos = [CCSprite spriteWithFile:@"sky.png"];
		}
		else {
			atmos = [CCSprite spriteWithFile:@"sky-low.png"];
		}
		
		atmos.scale = [CCDirector sharedDirector].winSize.width / atmos.contentSize.width;
		atmos.position = ccp(0, radius+(atmos.contentSize.height * atmos.scale) / 16.0);
		[self addChild:atmos];
		
		CCSprite *qp1 = [CCSprite spriteWithFile:@"pixplanet2.png"];
		CCSprite *qp2 = [CCSprite spriteWithFile:@"pixplanet2.png"];
		CCSprite *qp3 = [CCSprite spriteWithFile:@"pixplanet2.png"];
		CCSprite *qp4 = [CCSprite spriteWithFile:@"pixplanet2.png"];
		
		/*
		[qp1.texture setAliasTexParameters];
		[qp2.texture setAliasTexParameters];
		[qp3.texture setAliasTexParameters];
		[qp4.texture setAliasTexParameters];
		*/
		
		if (radius != -1) {
			qp1.scaleX = radius / qp1.contentSize.width; qp1.scaleY = radius / qp1.contentSize.height;
			qp2.scaleX = radius / qp1.contentSize.width; qp2.scaleY = radius / qp1.contentSize.height;
			qp3.scaleX = radius / qp1.contentSize.width; qp3.scaleY = radius / qp1.contentSize.height;
			qp4.scaleX = radius / qp1.contentSize.width; qp4.scaleY = radius / qp1.contentSize.height;
		}
		
		qp1.anchorPoint = ccp(0, 0);
		qp2.anchorPoint = ccp(0, 0);
		qp3.anchorPoint = ccp(0, 0);
		qp4.anchorPoint = ccp(0, 0);

		qp2.rotation = 90;
		qp3.rotation = 180;
		qp4.rotation = 270;

		_planetnode = [CCNode node];
		
		[_planetnode addChild:qp1];
		[_planetnode addChild:qp2];
		[_planetnode addChild:qp3];
		[_planetnode addChild:qp4];

		_shakenode = [CCNode node];
		
		[_shakenode addChild:_planetnode];
		[self addChild:_shakenode];
		
		self.position = p;
		
		_shaking = NO;
		_shakeStart = -1;
		
	}
	return self;
}

- (id) initAt: (CGPoint) pos upsideDown: (BOOL) isUpsidedown {
	if ((self = [super init])) {
		
		_health = 0;
		
		// atmosphere
		
		CCSprite *atmos;
		
		if (_IPAD) {
			atmos = [CCSprite spriteWithFile:@"sky.png"];
		}
		else {
			atmos = [CCSprite spriteWithFile:@"sky-low.png"];
		}
		
		atmos.scale = [CCDirector sharedDirector].winSize.width / atmos.contentSize.width;
		atmos.position = ccp(0, -150 + atmos.scale * atmos.contentSize.height / 2.0);
		[self addChild:atmos];
				
		
		// mountains
		
		_mountainsnode[0] = [CCNode node];
		_mountainsnode[1] = [CCNode node];

		CCSprite *mountains1;
		CCSprite *mountains2;
		
		if (_IPAD) {
			mountains1 = [CCSprite spriteWithFile:@"mountains1.png"];
			mountains2 = [CCSprite spriteWithFile:@"mountains1.png"];
		}
		else {
			mountains1 = [CCSprite spriteWithFile:@"mountains1-low.png"];
			mountains2 = [CCSprite spriteWithFile:@"mountains1-low.png"];
		}
		
		mountains1.position = ccp(0, -15 + mountains1.contentSize.height/2.0);
		mountains2.position = ccp(mountains1.contentSize.width -1 , -15 +  mountains2.contentSize.height/2.0);

		[_mountainsnode[0] addChild:mountains1];
		[_mountainsnode[0] addChild:mountains2];
		
		mountains1 = [CCSprite spriteWithFile:@"mountains2.png"];
		mountains2 = [CCSprite spriteWithFile:@"mountains2.png"];
		
		if (_IPAD) {
			mountains1 = [CCSprite spriteWithFile:@"mountains2.png"];
			mountains2 = [CCSprite spriteWithFile:@"mountains2.png"];
		}
		else {
			mountains1 = [CCSprite spriteWithFile:@"mountains2-low.png"];
			mountains2 = [CCSprite spriteWithFile:@"mountains2-low.png"];
		}
		
		mountains1.position = ccp(0, -15 + mountains1.contentSize.height/2.0);
		mountains2.position = ccp(mountains1.contentSize.width -1 , -15 +  mountains2.contentSize.height/2.0);
		
		[_mountainsnode[1] addChild:mountains1];
		[_mountainsnode[1] addChild:mountains2];
		_mountainsnode[1].visible = NO;
		
		//ccTexParams tp = {GL_NEAREST, GL_NEAREST, GL_REPEAT, GL_REPEAT};
		//[mountains1.texture setTexParameters:&tp];
		//[mountains2.texture setTexParameters:&tp];

		_shakenode = [CCNode node];
		
		[_shakenode addChild:_mountainsnode[0]];
		[_shakenode addChild:_mountainsnode[1]];
		
		// city
		
		for (int i=0; i<4; i++) 
		{
			CCSprite *city1;
			CCSprite *city2;
			
			if (_IPAD) {
				city1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"city%d.png", i+1]];
				city2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"city%d.png", i+1]];
			}
			else {
				city1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"city%d-low.png", i+1]];
				city2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"city%d-low.png", i+1]];
			}
			
			city1.position = ccp(0, city1.contentSize.height/2.0);
			city2.position = ccp(city1.contentSize.width,city2.contentSize.height/2.0);
			//[city1.texture setAliasTexParameters];
			//[city2.texture setAliasTexParameters];

			_citynode[i] = [CCNode node];
			_citynode[i].visible = NO;
			
			[_citynode[i] addChild:city1];
			[_citynode[i] addChild:city2];
			
			[_shakenode addChild:_citynode[i]];
		}
		
		_citynode[0].visible = YES;
		
		[self addChild:_shakenode];
		
		self.position = pos;
		if (isUpsidedown) {
			self.rotation = 180;
			_upsidedown = YES;
		}
		
		_shaking = NO;
		_shakeStart = -1;
	}
	return self;
}


- (id) init {
	return [self initAt:ccp(0, 0) withRadius: -1];
}

-(void) tick: (ccTime)dt {
	
	// handle planet shake stuff
	
	if (_shaking && (_shakeStart < 0)) {
		_shakeStart = 0;
	}
	
	if (_shakeStart >=0 ) {
		_shakeStart += dt;
		_shakenode.position = ccp(rand() % 10 - 5, rand() % 10 - 5);
	}
	
	if (_shakeStart > PLANET_SHAKE_DURATION / 2.0) {
		_shakeStart = -1;
		_shaking = NO;
		_shakenode.position = ccp(0,0);
	}
	
	// handle regen stuff
	
	_regenTime += dt;
	if (_regenTime > PLANET_REGEN_TIME) {
		[self doRegen];
	}
	
	// handle parallax motion
	
	for (int i=0; i<4; i++) {
		_citynode[i].position = ccp(_citynode[i].position.x - dt * PLANET_MOTION_FACTOR, 0);
		if (_citynode[i].position.x < -((CCSprite *) [[_citynode[i] children] objectAtIndex:0]).contentSize.width + 1 ) {
			_citynode[i].position = ccp(0, 0);
		}
	}
	
	for (int i=0; i<2; i++) {
		_mountainsnode[i].position = ccp(_mountainsnode[i].position.x - dt * PLANET_MOTION_FACTOR * PLANET_PARALAX_RATIO, 0);
		if (_mountainsnode[i].position.x < -((CCSprite *) [[_mountainsnode[i] children] objectAtIndex:0]).contentSize.width + 1) {
			_mountainsnode[i].position = ccp(0, 0);
		}	
	}
	
	//planetnode.rotation += dt * M_PI/SOLAR_ROT_FACTOR;
}

-(BOOL) doHit {
	if ([self isDead]) return NO;
	
	_health -= 1;
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"planet.wav"];
	
	//printf("hit to %d:\n", health);

	for (int i=0; i<4; i++) _citynode[i].visible = NO;
	for (int i=0; i<2; i++) _mountainsnode[i].visible = NO;
	
	// manually override destruction
	/*
	if (health > -PLANET_MAX_HEALTH) {
		citynode[(int)((-health/PLANET_MAX_HEALTH)*4)].visible = YES;
		mountainsnode[(int)((-health/PLANET_MAX_HEALTH)*2)].visible = YES;
	}
	*/
	
	if (_health == -1) {
		_citynode[1].visible = YES;
		_mountainsnode[0].visible = YES;
	}
	else if (_health == -2) {
		_citynode[2].visible = YES;
		_mountainsnode[0].visible = YES;
	}
	else if (_health == -3) {
		_citynode[2].visible = YES;
		_mountainsnode[1].visible = YES;
	}
	else if (_health == -4) {
		_citynode[3].visible = YES;
		_mountainsnode[1].visible = YES;
	}
	else {
		_citynode[3].visible = YES;
		_mountainsnode[1].visible = YES;
	}
	
	if (_health == -(PLANET_MAX_HEALTH-2)) {
		id action1 = [CCActionTween actionWithDuration:0.5 key:@"RedTint" from:0 to:1];
		id action2 = [CCActionTween actionWithDuration:0.5 key:@"RedTint" from:1 to:0];
		CCRepeatForever *repeat_act = [CCRepeatForever actionWithAction:[CCSequence actions:action1, action2, nil]];
		repeat_act.tag = ACTION_TAG_FLASHING;
		[self runAction:repeat_act];		
	}
	
	/*
	 [planetnode runAction:
	 [CCEaseExponentialOut actionWithAction:
	 [CCMoveTo actionWithDuration:PLANET_DRIFT_DURATION 
	 position:ccp(0, PLANET_DRIFT * health)]]];
	 
	 [planetnode runAction:
	 [CCEaseExponentialOut actionWithAction:
	 [CCRotateBy actionWithDuration:PLANET_DRIFT_DURATION angle:PLANET_SPIN]]];
	 */
	_shaking = YES;
	
	_regenTime = 0;
	
	return YES;
}

-(void) doRegen {
	
	if ([self isDead]) return;
	
	if (_health < 0) _health++;
	
	//printf("regen to %d:\n", health);
	
	for (int i=0; i<4; i++) _citynode[i].visible = NO;
	for (int i=0; i<2; i++) _mountainsnode[i].visible = NO;
	
	if (_health > -PLANET_MAX_HEALTH) {
		_citynode[(int)((-_health/PLANET_MAX_HEALTH)*4)].visible = YES;
		_mountainsnode[(int)((-_health/PLANET_MAX_HEALTH)*2)].visible = YES;
	}
	
	[self stopAction:[self getActionByTag:ACTION_TAG_FLASHING]];
	self.redTint = 0;
	
	_regenTime = 0;
}

- (void) reset {
	_health = 0;

	for (int i=0; i<4; i++) _citynode[i].visible = NO;
	for (int i=0; i<2; i++) _mountainsnode[i].visible = NO;
	
	_citynode[0].visible = YES;
	_mountainsnode[0].visible = YES;
	
	/*
	[planetnode runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCMoveTo actionWithDuration:PLANET_DRIFT_DURATION position:ccp(0, 0)]]];
	*/
	
	_shaking = NO;
	_shakeStart = -1;
	_regenTime = 0;
	
	_shakenode.position = ccp(0,0);

	[self stopAction:[self getActionByTag:ACTION_TAG_FLASHING]];
	self.redTint = 0;
}

- (BOOL) isDead
{
	return _health <= -(PLANET_MAX_HEALTH-1);
}

- (float) redTint { return _redTint; }

- (void) setRedTint:(float) tint {
	// not this gets called repeatedly with values from 0-1. It would be best to only take action when there is a 
	// transition over the .5 threshold, rather than computing new color constantly as I do below
	_redTint = tint;
	for (int i=0; i<4; i++) {
		for (CCSprite *child in [_citynode[i] children]) {
			if (tint > 0.5) [child setColor:ccc3(255, 128, 128)];
			else [child setColor:ccc3(255, 255, 255)];
		}
	}
	for (int i=0; i<2; i++) {
		for (CCSprite *child in [_mountainsnode[i] children]) {
			if (tint > 0.5) [child setColor:ccc3(255, 128, 128)];
			else [child setColor:ccc3(255, 255, 255)];
			//[child setColor:ccc3(child.color.r + tint, child.color.g - tint, child.color.b - tint)];
		}
	}
}

@end

