//
//  DynamicInvader.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/21/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteBody.h"
#import "Ball.h"
#import "Shooter.h"
#import "GameSettings.h"

#define DYN_DETONATION 300

@interface DynamicInvader : SpriteBody<Shooter> {
	int _health;
	float _detonationTimer;
	Ball *_lastBall;
}

@property (readwrite, assign) int health;
@property (readwrite, assign) float detonationTimer;
@property (readwrite, assign) Ball *lastBall;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w;

- (Ball *) ballWithDirection: (CGPoint) dir;
- (void) makeActive;
- (void) doKill;
- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage;
- (void) doHitScore: (Ball *) ball;
- (void) doDestroyedScore: (Ball *) ball;
- (BOOL) isDead;
- (void) reset;
- (void) moveWithDir: (CGPoint) p andDistance: (int) d;
-(void) tick: (ccTime)dt;

@end
