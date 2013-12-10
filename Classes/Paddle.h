//
//  Paddle.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticSpriteBody.h"
#import "Player.h"
#import "GameSettings.h"
#import "Ball.h"


@interface Paddle : SpriteBody {
	Player *_player;
	int _state;
	float _stateRemaining;
	float _lastShot;
}

@property (nonatomic, retain) Player *player;
@property (readwrite, assign) int state;
@property (readwrite, assign) float stateRemaining;
@property (readwrite, assign) float lastShot;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w;
- (void) moveTo: (int) x;
- (void) tintEffect:(int)e;
- (void) extend;
- (void) shrink;
- (CGRect) getRect;
- (void) doHitFrom: (Ball *) ball withDamage: (int) d;

@end