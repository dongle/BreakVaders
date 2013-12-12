//
//  CDRBobble.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/1/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "CDRBobble.h"
#import "PongVaderScene.h"
#define RADIANS( degrees ) ( degrees * M_PI / 180 )

@implementation CDRBobble
+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	CDRBobble *invader;
	
	invader = [CDRBobble spriteWithSpriteFrameName:@"invader1_walk1.png"];
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
		[animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader1_walk%d.png", i]]];
	}
	invader.idle = [CCAnimation animationWithSpriteFrames:animFrames delay:GAME_SPB/3.0f];
	
	NSMutableArray *armoredFrames = [NSMutableArray array];
	for (int i=1; i<=6; i++) {
		[armoredFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader1_armored%d.png", i]]];
	}
	invader.armored = [CCAnimation animationWithSpriteFrames:armoredFrames delay:GAME_SPB/3.0f];
	
	NSMutableArray *popFrames = [NSMutableArray array];
	for (int i=1; i<=4; i++) {
		[popFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"invader1_pop%d.png", i]]];
	}
	invader.pop = [CCAnimation animationWithSpriteFrames:popFrames delay:GAME_SPB/8.0f];
	
	if (w) [invader createBodyInWorld: w];
	
	return invader;
}

- (void) shoot {
	int angle;
	int dir = arc4random() % 2;
	float magnitude;
	for (int i = 1; i < 4; i++) {
		angle = 160 + 10*i;
		if (dir == 0) { angle += 180; }
		
		magnitude = [[PongVader getInstance] randBallMagnitude];
		CGPoint force = ccp(magnitude*sin(RADIANS(angle)), magnitude*cos(RADIANS(angle)) );
		
		Ball *newball = [self ballWithDirection:force ];
		[[PongVader getInstance] addChild:newball];
		[[PongVader getInstance].balls addObject:newball];
	}
	
	[[SimpleAudioEngine sharedEngine] playEffect:@"shoot.wav"];
}


- (void) doDestroyedScore: (Ball *) ball {
	[ball.lastPlayer incScoreBy:SCORE_DESTROYCDR*ball.combo];	
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