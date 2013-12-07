//
//  Planet.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GameSettings.h"

@interface Planet : CCNode {
	CCNode *planetnode, *shakenode, *skynode, *citynode[4], *mountainsnode[2];
	int health;
	BOOL shaking, upsidedown;
	ccTime shakeStart, regenTime;
	float redTint;
}

@property(readonly) BOOL shaking;
@property (readwrite, assign) float redTint;
@property (readonly) int health;

- (id) initAt: (CGPoint) pos upsideDown: (BOOL) isUpsidedown;
- (void) tick: (ccTime)dt;
- (BOOL) doHit;
- (void) doRegen;
- (void) reset;
- (BOOL) isDead;
@end
