//
//  Ball.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "Ball.h"
#import "Invader.h"
#import "PongVaderScene.h"
#import "SimpleAudioEngine.h"

@implementation Bounce
@synthesize pos = _pos;
@synthesize hit = _hit;

- (id) initWithPos: (CGPoint) p hit: (id) h { 
	if ((self=[super init])) {
		_pos=p;
		_hit=h;
	}
	return self;
}
+ (id) bounceWithPos: (CGPoint) p hit: (id)h {
	return [[[Bounce alloc] initWithPos:p hit:h] autorelease];
}
@end

@implementation Ball

@synthesize lastPlayer = _lastPlayer;
@synthesize health = _health;
@synthesize combo = _combo;
@synthesize volley = _volley;
@synthesize isBulletTime = _isBulletTime;
@synthesize AIOffset = _AIOffset;
@synthesize isNuke = _isNuke;
@synthesize strobeTime = _strobeTime;
@synthesize bounces = _bounces;
@synthesize ribbon = _ribbon;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	// Create sprite and add it to the layer
	Ball *ball;
	
	if (_IPAD) {
		ball = [Ball spriteWithSpriteFrameName:@"BallDoubleHollow.png"];
	}
	else {
		ball = [Ball spriteWithSpriteFrameName:@"hollowBall.png"];
	}
	
	//Ball *ball = [Ball spriteWithSpriteFrameName:@"hollowBall.png" rect:CGRectMake(0, 0, 2*BALL_RADIUS, 2*BALL_RADIUS)
	
	NSMutableArray *animFrames = [NSMutableArray array];
	if (_IPAD) {
		[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BallDouble.png"]];
	}
	else {
	[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"hollowBall.png"]];
	}
	ball.idle = [CCAnimation animationWithName:@"idle" delay:GAME_SPB/3.0f frames:animFrames];
	
	NSMutableArray *armoredFrames = [NSMutableArray array];
	if (_IPAD) {
		[armoredFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BallDouble.png"]];
	}
	else {
		[armoredFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Ball.png"]];
	}
	ball.armored = [CCAnimation animationWithName:@"armored" delay:GAME_SPB/3.0f frames:armoredFrames];
	
	ball.position = p;
	ball.world = w;
//	if (_IPAD) {
//		ball.scale = 2.0;
//	}
	
	// Create ball body and add to ball SpriteBody
	b2BodyDef ballBodyDef;
	ballBodyDef.type = b2_dynamicBody;
	ballBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	ballBodyDef.userData = ball;
	b2Body *ballBody = w->CreateBody(&ballBodyDef);
	ball.b2dBody = ballBody;
	ballBody->SetFixedRotation(1);
	
	// Create circle shape
	b2CircleShape circle;
	if (_IPAD) {
		circle.m_radius = (float) BALL_RADIUS/PTM_RATIO;
	}
	else {
		circle.m_radius = (float) BALL_RADIUS_PHN/PTM_RATIO;
	}
	
	// Create shape definition and add to body
	b2FixtureDef ballShapeDef;
	ballShapeDef.shape = &circle;
	ballShapeDef.density = 1.0f;
	ballShapeDef.friction = 0.0f;
	ballShapeDef.restitution = 1.0f;
	ballShapeDef.filter.categoryBits = COL_CAT_BALL;
	ballShapeDef.filter.maskBits = 0xFFFF & ~(COL_CAT_BALL | COL_CAT_INVADER | COL_CAT_DYNVADER);
	ballBody->CreateFixture(&ballShapeDef);
	
	// Give shape initial impulse
	b2Vec2 force = b2Vec2(f.x, f.y);
	ball.b2dBody->ApplyLinearImpulse(force, ballBodyDef.position);
	
	ball.health = BALLHITS;
	ball.combo = 1;
	ball.volley = 0;
	
	if (_IPAD) {
		ball.AIOffset = arc4random() % 100;
		ball.AIOffset -= 50;
	}
	else {
		ball.AIOffset = arc4random() % 50;
		ball.AIOffset -= 25;
	}

	ball.strobeTime = 0;
	
	ball.bounces = [NSMutableArray arrayWithCapacity:10];
	ball.ribbon = nil;
	
	// NSLog(@"created ball %@", ball);

	return ball;
}

- (BOOL) doHit: (NSObject *) hitwhat {
	// don't need to filter double-contacts anymore since cole ninja-ed the
	// contact listener
	//if (lastHit == hitwhat) return NO;
	_lastHit = hitwhat;
	
	[self addBounceAgainst:hitwhat];
	
	if ([_lastHit isKindOfClass:[Player class]]) {
		
		
		if (_lastPlayer != (Player *) _lastHit) {
			_volley +=1;
		}
		
		if ([self isHot]) {
			[self doKill];
		}
		
		[self runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:self.armored restoreOriginalFrame:NO]]];

		// set ball filter so that it will collide with invaders
		b2Fixture *fixture = _b2dBody->GetFixtureList();
		b2Filter filter = fixture->GetFilterData();
		filter.maskBits = 0xFFFF & ~COL_CAT_BALL;
		fixture->SetFilterData(filter);
		
		if ((_volley == 2) && ![self isHot]) {
			[self makeFireball];
		}

		_lastPlayer = (Player *) _lastHit;
		

	}

	return YES;
}

- (void) makeFireball {
	[self runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:self.armored restoreOriginalFrame:NO]]];
	if (_health > 1) {
		_health = 1;
	}
	_isFireball = YES;
	
	// TODO: is it necessary to do this twice?
	// set ball filter so that it will collide with invaders
	b2Fixture *fixture = _b2dBody->GetFixtureList();
	b2Filter filter = fixture->GetFilterData();
	filter.maskBits = 0xFFFF & ~COL_CAT_BALL;
	fixture->SetFilterData(filter);
	
	[self setColor:ccc3(255, 0, 0)];
	
	if (_IPAD) {
//		streak = [CCMotionStreak streakWithFade:.5 minSeg:3 image:@"Ball.png" width:16 length:16 color:ccc4(255,0,0,128)];
        _streak = [CCMotionStreak streakWithFade:.5 minSeg:3 width:16 color:ccc3(255, 0, 0) textureFilename:@"Ball.png"];
//		ribbon = [CCMotionStreak streakWithWidth:8 image:@"Ball.png" length:16 color:ccc4(128,128,128,128) fade:RIBBON_FADE_TIME];
        _ribbon = [CCMotionStreak streakWithFade:RIBBON_FADE_TIME minSeg:3 width:8 color:ccc3(128, 128, 128) textureFilename:@"Ball.png"];
	}
	else {
        _streak = [CCMotionStreak streakWithFade:.5 minSeg:3 width:8 color:ccc3(255, 0, 0) textureFilename:@"Ball.png"];
        _ribbon = [CCMotionStreak streakWithFade:RIBBON_FADE_TIME minSeg:3 width:8 color:ccc3(128, 128, 128) textureFilename:@"Ball.png"];
	}
	
	_streak.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
	//ribbon.position = ccp(self.contentSize.width/2, self.contentSize.height/2);

	PongVader *PV = [PongVader getInstance];

	unsigned int start = 0;

	for (int i=[_bounces count]-1; i>=0; i--) {
		Bounce *b = [_bounces objectAtIndex:i];
		if (b.hit == _lastPlayer) {
			start = i;
			break;
		}
	}
	
	CGPoint lastPoint = ccp(-1,-1);
	for (unsigned int i=start; i<[_bounces count]; i++) {
		Bounce *b = [_bounces objectAtIndex:i];
		CGPoint p = b.pos;

		if (i==start && RIBBON_TO_CUR_POS) {
				p = b.hit==PV.paddle1.player?PV.paddle1.position:PV.paddle2.position;
		}

		float maxwidth = (_IPAD)?16:8;
		float width = maxwidth;
		if (RIBBON_TAPER) float width = (0.5*maxwidth/([_bounces count]-start)) * ((i-start)*2.0);
		if (lastPoint.x > -1) {
			[_ribbon addPointAt:ccp((lastPoint.x+p.x)/2.0, (lastPoint.y+p.y)/2.0) width:width];
			[_ribbon update:RIBBON_FADE_TIME/(2.0*[_bounces count])];
		}
		if (RIBBON_TAPER) width = (0.5*maxwidth/([_bounces count]-start)) * ((i-start)*2.0+1);
		[_ribbon addPointAt:p width:width];
		lastPoint = p;

		if (i<[_bounces count]-1) [_ribbon update:RIBBON_FADE_TIME/(2.0*[_bounces count])];
	}

	[self addChild:_streak];
	[[PongVader getInstance] addChild:_ribbon];
	
	//[ribbon runAction:[CCFadeOut actionWithDuration:RIBBON_FADE_TIME]];
	
	[PongVader getInstance].gotFireball = YES;
	
	//NSLog(@"Made Fireballball %@", self);
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"charge.wav"];

}

- (BOOL) doKill {
	_health = 0;
	_strobeTime = 0;
	[self setColor:ccc3(255, 255, 255)];

	return YES;
}

- (BOOL) isDead {
	return _health <= 0;
}

- (BOOL) isHot {
	return _isFireball;
}

- (BOOL) isWhite {
	return !_isFireball && (_volley > 0);
}

- (void) increaseCombo {
    _combo += 1;
	if (_combo > _lastPlayer.maxCombo) {
		_lastPlayer.maxCombo = _combo;
	}
}

- (void) resetCombo {
	_combo = 1;
}

- (void) enterBulletTime {
	if (!_isBulletTime) {
		if (!_isFireball){
			
			if (_IPAD) {
				_streak = [CCMotionStreak streakWithFade:2 minSeg:3 image:@"Ball.png" width:16 length:8 color:ccc4(255,255,255,128)];
			}
			else {
				_streak = [CCMotionStreak streakWithFade:2 minSeg:3 image:@"Ball.png" width:8 length:4 color:ccc4(255,255,255,128)];
			}
		}
		
		else {
			if (_IPAD) {
				_streak = [CCMotionStreak streakWithFade:2 minSeg:3 image:@"Ball.png" width:16 length:16 color:ccc4(255,0,0,128)];
			}
			else {
				_streak = [CCMotionStreak streakWithFade:2 minSeg:3 image:@"Ball.png" width:8 length:8 color:ccc4(255,0,0,128)];
			}
		}
		
		
		_streak.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
		[self addChild:_streak];
		
	}
	_isBulletTime = YES;
}

- (void) exitBulletTime {
	if (!_isFireball){
		[self removeChild:_streak cleanup:YES];
	}
	_isBulletTime = NO;
}

- (void) strobe: (float) time {
	_strobeTime += time;
	int k = sin(_strobeTime*10)*128;
	[self setColor:ccc3(255, 255-k, 255-k)];
}

- (void) addBounceAgainst: (id) thing {
	if ([_bounces count] >= MAX_BOUNCES) {
		[_bounces removeObjectAtIndex:0];
	}
	[_bounces addObject:[Bounce bounceWithPos:self.position hit:thing]];
	//NSLog(@"Bounced at (%5.2f, %5.2f) (%@)\n", self.position.x, self.position.y, [[thing class] description]);
}

- (void) updateRibbon: (ccTime) dt {
	if (_ribbon) [_ribbon update:dt];
}

- (void) cleanup {
	[[PongVader getInstance] removeChild:_ribbon cleanup: YES];
}

- (void) dealloc 
{
	[_bounces removeAllObjects];
	[_bounces release];
	[super dealloc];
}

- (void) doHitFrom: (Ball *) ball withDamage: (int) d {
	return;
}

@end
