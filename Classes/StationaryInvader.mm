//
//  StationaryInvader.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StationaryInvader.h"
#import "Box2D.h"
#import "PongVaderScene.h"

@implementation StationaryInvader

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	StationaryInvader *invader = [StationaryInvader spriteWithSpriteFrameName:@"static1.png"];
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
	[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"static1.png"]];
	[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"static2.png"]];
	[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"static1.png"]];
	[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"static3.png"]];
	invader.idle = [CCAnimation animationWithName:@"idle" delay:0.25 frames:animFrames];

	NSMutableArray *popFrames = [NSMutableArray array];
	for (int i=1; i<=4; i++) {
		[popFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"static_pop%d.png", i]]];
	}
	invader.pop = [CCAnimation animationWithName:@"pop" delay:GAME_SPB/8.0f frames:popFrames];
	
	if (w) [invader createBodyInWorld: w];
	
	return invader;
}

- (Ball *) ballWithDirection: (CGPoint) dir
{
	CGPoint pos = ccp(self.position.x, self.position.y);
	return (Ball *) [Ball spriteBodyAt:pos withForce: dir inWorld:world];
}

- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	if ([self isDead]) return NO;
	
	if (ball.isNuke) [super doHitFrom: ball withDamage: damage];
	
	return YES;
}

//- (void) doDestroyedScore: (Ball *) ball {
//	[ball.lastPlayer incScoreBy:SCORE_DESTROYLT*ball.combo];
//}

- (void) doDestroyedScore: (Ball *) ball {
	[super doDestroyedScore:ball];
}

- (BOOL) doesCount { return NO; }

@end
