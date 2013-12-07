//
//  ADMBrainSeg.mm
//  MultiBreakout
//
//  Created by Cole Krumbholz on 9/22/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "ADMBrainSeg.h"
#import "PongVaderScene.h"

@implementation ADMBrainSeg
+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	ADMBrainSeg *invader;
	
	invader = [ADMBrainSeg spriteWithSpriteFrameName:@"boss3_bigsegment.png"];
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
	
	invader->head = nil;
	
	if (w) [invader createBodyInWorld: w];
	
	return invader;
}

- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage {
	//if (head) [head doHitFrom:ball withDamage:damage];
	return YES;
}


- (void) doDestroyedScore: (Ball *) ball {
	[ball.lastPlayer incScoreBy:SCORE_DESTROYENS*ball.combo];
}

-(BOOL) isBoss {return YES;}

- (void) reset {
	health = 1;
}

- (BOOL) doesCount {return NO;}

@end

@implementation ADMBrainSegSmall
+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	ADMBrainSeg *invader;
	
	invader = [ADMBrainSegSmall spriteWithSpriteFrameName:@"boss3_smallsegment.png"];
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
	
	if (w) [invader createBodyInWorld: w];
	
	return invader;
}

@end
