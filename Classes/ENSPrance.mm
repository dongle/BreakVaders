//
//  ENSPrance.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/1/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ENSPrance.h"
#import "PongVaderScene.h"

@implementation ENSPrance
+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	ENSPrance *invader;
	
	invader = [ENSPrance spriteWithSpriteFrameName:@"invader2_walk1.png"];
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
		[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader2_walk%d.png", i]]];
	}
//	invader.idle = [CCAnimation animationWithName:@"idle" delay:GAME_SPB/3.0f frames:animFrames];
    invader.idle = [CCAnimation animationWithSpriteFrames:animFrames delay:GAME_SPB/3.0f];
	
	NSMutableArray *armoredFrames = [NSMutableArray array];
	for (int i=1; i<=6; i++) {
		[armoredFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader2_armored%d.png", i]]];
	}
//	invader.armored = [CCAnimation animationWithName:@"armored" delay:GAME_SPB/3.0f frames:armoredFrames];
    invader.armored = [CCAnimation animationWithSpriteFrames:armoredFrames delay:GAME_SPB/3.0f];
	
	NSMutableArray *popFrames = [NSMutableArray array];
	for (int i=1; i<=4; i++) {
		[popFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader2_pop%d.png", i]]];
	}
//	invader.pop = [CCAnimation animationWithName:@"pop" delay:GAME_SPB/8.0f frames:popFrames];
    invader.pop = [CCAnimation animationWithSpriteFrames:popFrames delay:GAME_SPB/8.0f];
	
	if (w) [invader createBodyInWorld: w];
	
	return invader;
}

- (void) promote: (int) level {
	self.promoted = true;
	self.health = 2;
    [super promote:level];
}

- (void) removeArmor {
    [super removeArmor];
}

- (void) doDestroyedScore: (Ball *) ball {
	[ball.lastPlayer incScoreBy:SCORE_DESTROYENS*ball.combo];
}

@end
