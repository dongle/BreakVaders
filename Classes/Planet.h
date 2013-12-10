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
	CCNode *_planetnode, *_shakenode, *_skynode, *_citynode[4], *_mountainsnode[2];
	int _health;
	BOOL _shaking, _upsidedown;
	ccTime _shakeStart, _regenTime;
	float _redTint;
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
