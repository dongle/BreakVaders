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
#import "BVGameKitHelper.h"

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
@synthesize streak = _streak;
@synthesize fireballHits = _fireballHits;

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
	ball.idle = [CCAnimation animationWithSpriteFrames:animFrames delay:GAME_SPB/3.0f];
	
	NSMutableArray *armoredFrames = [NSMutableArray array];
	if (_IPAD) {
		[armoredFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"BallDouble.png"]];
	}
	else {
		[armoredFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Ball.png"]];
	}
	ball.armored = [CCAnimation animationWithSpriteFrames:armoredFrames delay:GAME_SPB/3.0f];
	
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
    ball.fireballHits = 0;
	
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
    
    ball.streak = nil;
	
	// NSLog(@"created ball %@", ball);

	return ball;
}

- (void)tick:(ccTime)dt
{
    [super tick:dt];
    if (_streak) _streak.position = self.position;
}

- (BOOL) doHit: (NSObject *) hitwhat {
	// don't need to filter double-contacts anymore since cole ninja-ed the
	// contact listener
	//if (lastHit == hitwhat) return NO;
	_lastHit = hitwhat;
	
	[self addBounceAgainst:hitwhat];
    
    if ([self isHot]) {
        NSLog(@"hit enemy while hot");
        _fireballHits += 1;
        if (_fireballHits >= 9) {
            [[BVGameKitHelper sharedGameKitHelper] submitAchievementId:BVAchievementFB9];
        } else if (_fireballHits >= 3) {
            [[BVGameKitHelper sharedGameKitHelper] submitAchievementId:BVAchievementFB3];
        }
    }
	
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
        _streak = [CCMotionStreak streakWithFade:.5 minSeg:3 width:16 color:ccc3(255, 0, 0) textureFilename:@"Ball.png"];
	}
	else {
        _streak = [CCMotionStreak streakWithFade:.5 minSeg:3 width:8 color:ccc3(255, 0, 0) textureFilename:@"Ball.png"];
	}
	
	_streak.position = self.position;

	unsigned int start = 0;

	for (int i=[_bounces count]-1; i>=0; i--) {
		Bounce *b = [_bounces objectAtIndex:i];
		if (b.hit == _lastPlayer) {
			start = i;
			break;
		}
	}

	[[PongVader getInstance] addChild:_streak];
	
	[PongVader getInstance].gotFireball = YES;
	
	//NSLog(@"Made Fireballball %@", self);
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"charge.wav"];

}

- (BOOL) doKill {
	_health = 0;
	_strobeTime = 0;
    _fireballHits = 0;
    PongVader *pv = [PongVader getInstance];
    [pv removeChild:_streak cleanup:YES];
    _streak = nil;
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
				_streak = [CCMotionStreak streakWithFade:2 minSeg:3 width:16 color:ccWHITE textureFilename:@"Ball.png"];
			}
			else {
				_streak = [CCMotionStreak streakWithFade:2.0f minSeg:3.0f width:8.0f color:ccWHITE textureFilename:@"Ball.png"];
			}
		}
		
		else {
			if (_IPAD) {
				_streak = [CCMotionStreak streakWithFade:2 minSeg:3 width:16 color:ccRED textureFilename:@"Ball.png"];
			}
			else {
				_streak = [CCMotionStreak streakWithFade:2.0f minSeg:3.0f width:8.0f color:ccRED textureFilename:@"Ball.png"];
			}
		}
		
		_streak.position = self.position;
		[[PongVader getInstance] addChild:_streak];
		
	}
	_isBulletTime = YES;
}

- (void) exitBulletTime {
	if (!_isFireball){
        PongVader *pv = [PongVader getInstance];
		[pv removeChild:_streak cleanup:YES];
        _streak = nil;
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
