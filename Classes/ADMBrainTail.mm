//
//  ADMBrainTail.mm
//  MultiBreakout
//
//  Created by Cole Krumbholz on 9/22/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ADMBrainTail.h"
#import "PongVaderScene.h"

@implementation ADMBrainTail
+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	ADMBrainTail *invader;
	
	invader = [ADMBrainTail spriteWithSpriteFrameName:@"boss3_tail1.png"];
	invader.position = p;
	invader.world = w;
	invader.health = 1;
	
	if (_IPAD) {
		invader.baseScale = 4.0;
		invader.scale = 4.0;
	}
	else {
		invader.baseScale = 2.0;
		invader.scale = 2.0;
	}
	
	
	NSMutableArray *animFrames = [NSMutableArray array];
	for (int i=1; i<=4; i++) {
		[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"boss3_tail%d.png", i]]];
	}
	invader.idle = [CCAnimation animationWithName:@"idle" delay:GAME_SPB/2.0f frames:animFrames];
	
	if (w) [invader createBodyInWorld: w];
	
	return invader;
}

- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	return YES;
}


- (void) doDestroyedScore: (Ball *) ball {
	[ball.lastPlayer incScoreBy:SCORE_DESTROYENS*ball.combo];
}

- (BOOL) doesCount {return NO;}

@end
