//
//  ShieldInvader.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/1/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ShieldInvader.h"
#import "PongVaderScene.h"
#import "Utils.h"

@implementation ShieldInvader
+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	ShieldInvader *invader;
	
	invader = [ShieldInvader spriteWithSpriteFrameName:@"invader1_walk1.png"];
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
		[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"dynamic_walk%d.png", i]]];
	}
	invader.idle = [CCAnimation animationWithName:@"idle" delay:GAME_SPB/3.0f frames:animFrames];
	
	NSMutableArray *popFrames = [NSMutableArray array];
	for (int i=1; i<=4; i++) {
		[popFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"dynamic_pop%d.png", i]]];
	}
	invader.pop = [CCAnimation animationWithName:@"pop" delay:GAME_SPB/8.0f frames:popFrames];
	
	if (w) [invader createBodyInWorld: w];
	
	return invader;
}


- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	if ([self isDead]) return NO;
	
	if ([ball isHot] || ball.isNuke) {
		
		// See dynamicInvader doHitFrom: for a special message
		[super doHitFrom:ball withDamage:damage];
		
		return ![ball isHot];
	}
	
	if ((self.rotation == 180 && (ball.position.y - self.position.y < 0)) ||  
		(self.rotation == 0 && (ball.position.y - self.position.y > 0))) {
		
		[super doHitFrom:ball withDamage:damage];
		
	}

	return ![ball isHot];
}

- (void) doDestroyedScore: (Ball *) ball {
	[ball.lastPlayer incScoreBy:SCORE_DESTROYSHLD*ball.combo];
}

- (void) promote: (int) level {
}

//- (void) shoot {
//}

@end
