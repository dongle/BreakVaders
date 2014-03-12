//
//  ADMBrain.mm
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/9/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ADMBrain.h"
#import "ADMBrainTail.h"
#import "ADMBrainSeg.h"
#import "BeatSequencer.h"
#import "PongVaderScene.h"
#import "Utils.h"
#import "GameSettings.h"

@implementation ADMBrain
@synthesize tail = _tail;
@synthesize fleet = _fleet;
@synthesize paused = _paused;
@synthesize upsidedown = _upsidedown;

- (void) dealloc {
	[_tail release];
	[super dealloc];
}

- (void) createBodyInWorld: (b2World *) w {
	// Create invader body
	b2BodyDef invBodyDef;
	invBodyDef.type = b2_staticBody;
	invBodyDef.position.Set(self.position.x/PTM_RATIO, self.position.y/PTM_RATIO);
	invBodyDef.userData = self;
	b2Body *invBody = w->CreateBody(&invBodyDef);
	
	b2Vec2 verts[8];
	
	if _IPAD {
		verts[0] = b2Vec2(-36.0f / PTM_RATIO, 60.0f / PTM_RATIO);
		verts[1] = b2Vec2(-92.0f / PTM_RATIO, 8.0f / PTM_RATIO);
		verts[2] = b2Vec2(-92.0f / PTM_RATIO, -32.0f / PTM_RATIO);
		verts[3] = b2Vec2(-32.0f / PTM_RATIO, -60.0f / PTM_RATIO);	
		verts[4] = b2Vec2(32.0f / PTM_RATIO, -60.0f / PTM_RATIO);
		verts[5] = b2Vec2(92.0f / PTM_RATIO, -32.0f / PTM_RATIO);
		verts[6] = b2Vec2(92.0f / PTM_RATIO, 8.0f / PTM_RATIO);
		verts[7] = b2Vec2(36.0f / PTM_RATIO, 60.0f / PTM_RATIO);
	}
	else {
		verts[0] = b2Vec2(-18.0f / PTM_RATIO, 30.0f / PTM_RATIO);
		verts[1] = b2Vec2(-46.0f / PTM_RATIO, 4.0f / PTM_RATIO);
		verts[2] = b2Vec2(-46.0f / PTM_RATIO, -16.0f / PTM_RATIO);
		verts[3] = b2Vec2(-16.0f / PTM_RATIO, -30.0f / PTM_RATIO);	
		verts[4] = b2Vec2(16.0f / PTM_RATIO, -30.0f / PTM_RATIO);
		verts[5] = b2Vec2(46.0f / PTM_RATIO, -16.0f / PTM_RATIO);
		verts[6] = b2Vec2(46.0f / PTM_RATIO, 4.0f / PTM_RATIO);
		verts[7] = b2Vec2(18.0f / PTM_RATIO, 30.0f / PTM_RATIO);
	}
	
	b2PolygonShape invShape;
	invShape.Set(verts, 8);
	
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
	

	ADMBrain *invader;
	
	invader = [ADMBrain spriteWithSpriteFrameName:@"boss3_head1.png"];
	invader.position = p;
	
	if (_IPAD) {
		invader.baseScale = 4.0;
		invader.scale = 4.0;	
	}
	else {
	invader.baseScale = 2.0;
	invader.scale = 2.0;
	}
	
	invader.world = w;
	
	invader->_bdir = CGNormalize(ccp(-1, 2));
	
	if _IPAD {
		invader->_bspeed = BRAIN_INIT_SPD; //pixels per second
		invader->_xmax = 668;
		invader->_xmin = 100;
		invader->_ymax = 724;
		invader->_ymin = 300;
		invader->_segcount = BRAIN_MAX_SEGS;
		invader.health = BRAIN_MAX_HEALTH;
	}
	
	else {
        BOOL isFourInch = [[PongVader getInstance] isFourInch];
        
		invader->_bspeed = BRAIN_INIT_SPD_IPHONE; //pixels per second
		invader->_xmax = 270;
		invader->_xmin = 50;
		invader->_ymax = isFourInch ? 330 + 44 : 330;
		invader->_ymin = isFourInch ? 150 + 44 : 150;
		invader->_segcount = BRAIN_MAX_SEGS_IPHONE;
		invader.health = BRAIN_MAX_HEALTH_IPHONE;
	}
	
	printf("brain segcount: %d", invader->_segcount);
	invader->_paused = NO;
	
	NSMutableArray *animFrames = [NSMutableArray array];
	int maxSegs;
	if _IPAD {
		maxSegs = BRAIN_MAX_SEGS;
	}
	else {
		maxSegs = BRAIN_MAX_SEGS_IPHONE;
	}
	for (int i=1; i<=BRAIN_NUM_FRAMES; i++) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"boss3_head%d.png", i]];
		[frame.texture setAliasTexParameters];
		[animFrames addObject:frame];		
	}
	
	for (int i=BRAIN_NUM_FRAMES; i>=1; i--) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"boss3_head%d.png", i]];
		[frame.texture setAliasTexParameters];
		[animFrames addObject:frame];		
	}

//	invader.idle = [CCAnimation animationWithName:@"idle" delay:GAME_SPB/8.0f frames:animFrames];
    invader.idle = [CCAnimation animationWithSpriteFrames:animFrames delay:GAME_SPB/8.0f];

	for (int i=0; i<=maxSegs; i++) {
		invader->_prevs[i] = p;
	}
	
	if (w) [invader createBodyInWorld: w];
	
	if _IPAD {
		invader->_scaleFactor = 1;
	}
	else {
		invader->_scaleFactor = .5;
	}

	return invader;
}

/*
- (void) cleanupSpriteBody {
	PongVader *pv = [PongVader getInstance];
	[pv destroyInvader:tail inGame:NO];
	for (int i=0; i<BRAIN_MAX_SEGS; i++) {
		[pv destroyInvader:segs[i] inGame:NO];
	}
}
*/

- (void) doRotate {
	if (_upsidedown) {
		self.rotation = 0;
		_b2dBody->SetTransform(_b2dBody->GetPosition(), 0);
	} else {
		self.rotation = 180;
		_b2dBody->SetTransform(_b2dBody->GetPosition(), RADIANS(180));
	}
	_upsidedown = !_upsidedown;
}

-(void) tick: (ccTime)dt {
	
	if (_paused) {
		return;
	}
	
	if (_shaking) {
		b2Vec2 vec = _b2dBody->GetPosition();
		int deltaPos = arc4random() % 10;
		self.position = ccp(vec.x*PTM_RATIO + deltaPos, vec.y*PTM_RATIO + deltaPos);
		_shakeTime+=dt;
		if (_shakeTime > 1) {
			_shaking = NO;
			_shakeTime = 0;
			self.position = ccp(vec.x*PTM_RATIO, vec.y*PTM_RATIO);
			//[self doRotate];
		}
	} else [super tick:dt];
	
	CGPoint N = ccp(0,0);
	if ((self.position.x > _xmax) && (_bdir.x>0)) N = ccp(-1, 0);
	if ((self.position.x < _xmin) && (_bdir.x<0)) N = ccp( 1, 0);
	if ((self.position.y > _ymax) && (_bdir.y>0)) N = ccp( 0,-1);
	if ((self.position.y < _ymin) && (_bdir.y<0)) N = ccp( 0, 1);

	if ((N.x != 0) || (N.y != 0)) {
		CGFloat d = CGDotProduct(_bdir, N);
		_bdir = ccp(_bdir.x-2*N.x*d,_bdir.y-2*N.y*d);

		if ((_bdir.y > 0) && (self.rotation == 180)) {
			[self doRotate];
		}
		if ((_bdir.y < 0) && (self.rotation == 0)) {
			[self doRotate];
		}
	}
	
	if (!_paused)
		self.position = ccp(self.position.x + _bdir.x*_bspeed*dt,
							self.position.y + _bdir.y*_bspeed*dt);

	if ([Utils distanceFrom:self.position to:_prevs[0]] > (BRAIN_SEG_DIST * _scaleFactor)) {
		for (int i=_segcount; i>0; i--) {
			_prevs[i] = _prevs[i-1];
		}
		_prevs[0] = self.position;
	}
	
	// determine closest ball to tail
	PongVader *pv = [PongVader getInstance];
	Ball *closest = [pv closestBallTo: _segs[_segcount/2].position maxDist:_segcount*(BRAIN_SEG_DIST * _scaleFactor)*1.2];
	CGPoint cp = closest?closest.position:_prevs[_segcount];
	float seekfac = closest?BRAIN_SEEK_FAC:0;
	
	for (int i=0; i<_segcount; i++) {
		float frac = i/(float)_segcount;
		float angle = M_PI*frac/2.0;
		float segwt = 1-cos(angle);
		//float seekweight = (1-BRAIN_SMOOTH_FAC) * (BRAIN_SEEK_FAC-(segcount-i)*BRAIN_WHIP_FAC);
		
		_segs[(_segcount-1)-i].position = ccp(
			BRAIN_SMOOTH_FAC*_segs[(_segcount-1)-i].position.x+(1-BRAIN_SMOOTH_FAC)*(1-seekfac*segwt)*_prevs[i].x+(1-BRAIN_SMOOTH_FAC)*seekfac*segwt*cp.x,
			BRAIN_SMOOTH_FAC*_segs[(_segcount-1)-i].position.y+(1-BRAIN_SMOOTH_FAC)*(1-seekfac*segwt)*_prevs[i].y+(1-BRAIN_SMOOTH_FAC)*seekfac*segwt*cp.y);
			//(segs[(segcount-1)-i].position.y*2+prevs[i].y)/3.0);
	}
	
	//float seekweight = (1-BRAIN_SMOOTH_FAC) * BRAIN_SEEK_FAC;

	_tail.position = ccp(
		BRAIN_SMOOTH_FAC*_tail.position.x+(1-BRAIN_SMOOTH_FAC)*(1-seekfac)*_prevs[_segcount].x+(1-BRAIN_SMOOTH_FAC)*seekfac*cp.x,
		BRAIN_SMOOTH_FAC*_tail.position.y+(1-BRAIN_SMOOTH_FAC)*(1-seekfac)*_prevs[_segcount].y+(1-BRAIN_SMOOTH_FAC)*seekfac*cp.y);
		//(tail.position.y*2+prevs[segcount].y)/3.0);
}

- (Ball *) ballWithDirection: (CGPoint) dir {
	CGPoint pos = ccp(self.position.x, self.position.y);
	if (_upsidedown) pos.y += 32 * _scaleFactor; else pos.y -= 32 * _scaleFactor;
	return (Ball *) [Ball spriteBodyAt:pos withForce: dir inWorld:_world];
}

- (void) nowShoot: (NSNumber *) ang {
	if ([self isDead]) return;

	CGSize ssz = [CCDirector sharedDirector].winSize;
	if ((self.position.x > ssz.width)  || (self.position.x < 0) || 
		(self.position.y > ssz.height) || (self.position.y < 0))
		return;
	
	float magnitude =[[PongVader getInstance] randBallMagnitude];
	int angle = [ang intValue];
	if (_upsidedown) angle +=180;
	CGPoint vel = _shaking?ccp(0,0):ccp(_bdir.x*_bspeed/(4*PTM_RATIO), _bdir.y*_bspeed/(4*PTM_RATIO));
	CGPoint force = ccp(magnitude*sin(RADIANS(angle))+vel.x, magnitude*cos(RADIANS(angle))+vel.y);
	
	if (!_IPAD) {
		force = ccp(.3*force.x, .3*force.y);
	}
	
	Ball *newball = [(Invader *)self ballWithDirection:force ];
	[[PongVader getInstance] addChild:newball];
	[[PongVader getInstance].balls addObject:newball];
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
}

- (void) unpause {
	_paused = NO;
}

- (void) shoot {
	//	paused = YES;
	
	NSUInteger beat = _fleet.lastBeat + 1;
	
	//float pulse = -sin(2*M_PI*fleet.lastBeat/(32.0*3))-sin(2*M_PI*fleet.lastBeat/(32.0*2));
	float pulse = -sin(2*M_PI*(8+2*beat)/(32.0*3));
	pulse = pulse<0?0:pulse;
	float pulsefac = 3;
	
	int spread = 45;
	int angle = -spread/2 + arc4random() % spread;
	[self nowShoot: [NSNumber numberWithInt:angle]];
	int speed = 2+arc4random()%2;
	int nshots;
	if _IPAD {
		nshots = 2+(int)((BRAIN_MAX_SEGS-_segcount)/2.0)+(int)(pulse*pulsefac)+arc4random()%2; //(2+(BRAIN_MAX_SEGS-segcount)/3);
	}
	else {
		nshots = 2+(int)((BRAIN_MAX_SEGS_IPHONE-_segcount)/2.0)+(int)(pulse*pulsefac)+arc4random()%2;
	}
	
	float delay = (15*speed)/[BeatSequencer getInstance].bpmin;
	
//	printf("                             segs: %d, base %2d, (measure: %2d.%d) pulse: %2d, nshots: %2d\n", _segcount, 2+((BRAIN_MAX_SEGS-_segcount)/2), 1+(beat/8)/4, 1+(beat/8)%4, (int)(pulse*pulsefac), nshots);
	
	for (int i=1; i<nshots; i++) {
		[self performSelector:@selector(nowShoot:) withObject:[NSNumber numberWithInt:angle+i*10] afterDelay:i*delay];
	}
	[self performSelector:@selector(unpause) withObject:nil afterDelay:nshots*delay];
}

- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	
	if (_shaking) return YES;
	
	//debug :
	if (ball == nil) { // ball should only be nil in the case of DEBUG_SKIPLEVEL
		[super doHitFrom:ball withDamage:damage];
		return YES;
	}
	
	if ([ball isHot] &&
		((!_upsidedown && (ball.position.y > (self.position.y-(25 * _scaleFactor)))) ||
		 (_upsidedown && (ball.position.y < (self.position.y+(25 * _scaleFactor)))))) {
			
			[[SimpleAudioEngine sharedEngine] playEffect:@"wail.wav"];
			[super doHitFrom:ball withDamage:1];
			
			printf("bosshealth: %d\n", _health);
				   
			if (![self isDead]) {
				_segs[_segcount-1].health -= 1;
				
				if (_segs[_segcount-1].health <= 0) {
					_shaking = YES;
					_segcount --;
					_bspeed += BRAIN_SPD_INC * _scaleFactor;
				}
				
			} else {
				for (int i=0; i<_segcount; i++) {
					_segs[i].health -=1;
				}
				_tail.health -=1;
			}
		}
		
	return YES;
}

-(BOOL) isBoss {return YES;}

- (void) reset {
	_health = BRAIN_MAX_HEALTH;
	self.rotation = 0;
	_b2dBody->SetTransform(_b2dBody->GetPosition(), 0);
	_upsidedown = NO;
	_bdir = CGNormalize(ccp(-1, 2));
	_bspeed = BRAIN_INIT_SPD * _scaleFactor; //pixels per second
	if _IPAD {
		_segcount = BRAIN_MAX_SEGS;
		_health = BRAIN_MAX_HEALTH;
	}
	else {
		_segcount = BRAIN_MAX_SEGS_IPHONE;
		_health = BRAIN_MAX_HEALTH_IPHONE;
	}
	_paused = NO;
}

@end
