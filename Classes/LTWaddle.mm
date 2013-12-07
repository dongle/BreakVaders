//
//  LTWaddle.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/1/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "LTWaddle.h"
#import "PongVaderScene.h"

@implementation LTWaddle
+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	LTWaddle *invader;
	
	invader = [LTWaddle spriteWithSpriteFrameName:@"invader3_walk1.png"];
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
	for (int i=1; i<=6; i++) {
		[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader3_walk%d.png", i]]];
	}
	invader.idle = [CCAnimation animationWithName:@"idle" delay:GAME_SPB/3.0f frames:animFrames];
	
	NSMutableArray *armoredFrames = [NSMutableArray array];
	for (int i=1; i<=6; i++) {
		[armoredFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader3_armored%d.png", i]]];
	}
	invader.armored = [CCAnimation animationWithName:@"armored" delay:GAME_SPB/3.0f frames:armoredFrames];
	
	NSMutableArray *popFrames = [NSMutableArray array];
	for (int i=1; i<=4; i++) {
		[popFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader3_pop%d.png", i]]];
	}
	invader.pop = [CCAnimation animationWithName:@"pop" delay:GAME_SPB/8.0f frames:popFrames];

	if (w) [invader createBodyInWorld: w];
	
	return invader;
}

//- (Ball *) ballWithDirection: (CGPoint) dir // should be handled by Invader
//{
//	CGPoint pos = ccp(self.position.x, self.position.y);
//	return (Ball *) [Ball spriteBodyAt:pos withForce: dir inWorld:world];
//}

- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	if ([self isDead]) return NO;
	
	//health -= 1;
	[super doHitFrom: ball withDamage: damage];
	
	// waddle releases 4 balls when destroyed
	if ([self isDead]) {
		
		Ball *newball;
		b2Fixture *f;
		b2Filter filter;
		
		float minSpeed = [PongVader getInstance].minSpeed;
		
		// up-right
		newball = [self ballWithDirection:ccp(minSpeed,minSpeed) ];
		newball.lastPlayer = ball.lastPlayer;
		newball.combo = ball.combo;
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		f = newball.b2dBody->GetFixtureList();
		filter = f->GetFilterData();
		filter.maskBits = 0xFFFF & ~COL_CAT_BALL;
		f->SetFilterData(filter);
		
		// up-left
		newball = [self ballWithDirection:ccp(-1.5*minSpeed,1.5*minSpeed) ];
		newball.lastPlayer = ball.lastPlayer;
		newball.combo = ball.combo;
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];		
		f = newball.b2dBody->GetFixtureList();
		filter = f->GetFilterData();
		filter.maskBits = 0xFFFF & ~COL_CAT_BALL;
		f->SetFilterData(filter);
		
		// down-left		
		newball = [self ballWithDirection:ccp(-minSpeed,-minSpeed) ];
		newball.lastPlayer = ball.lastPlayer;
		newball.combo = ball.combo;
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		f = newball.b2dBody->GetFixtureList();
		filter = f->GetFilterData();
		filter.maskBits = 0xFFFF & ~COL_CAT_BALL;
		f->SetFilterData(filter);
		
		// down-right		
		newball = [self ballWithDirection:ccp(1.5*minSpeed,-1.5*minSpeed) ];
		newball.lastPlayer = ball.lastPlayer;
		newball.combo = ball.combo;
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
		f = newball.b2dBody->GetFixtureList();
		filter = f->GetFilterData();
		filter.maskBits = 0xFFFF & ~COL_CAT_BALL;
		f->SetFilterData(filter);
		
		
	}
	
	return ![ball isHot];
}

- (void) doDestroyedScore: (Ball *) ball {
	[ball.lastPlayer incScoreBy:SCORE_DESTROYLT*ball.combo];
}

- (void) promote: (int) level {
	self.promoted = true;
	self.health = 2;
	[self runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:self.armored restoreOriginalFrame:NO] ]];
}

- (void) removeArmor {
	[self runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:self.idle restoreOriginalFrame:NO] ]];
}

@end
