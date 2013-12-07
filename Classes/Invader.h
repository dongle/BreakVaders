//
//  Invader.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/29/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticSpriteBody.h"
#import "Ball.h"
#import "Shooter.h"
#import "GameSettings.h"

@interface Invader : StaticSpriteBody<Shooter> {
	int health;
	BOOL promoted;
}

@property (readwrite, assign) int health;
@property (readwrite, assign) BOOL promoted;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w;
- (void) createBodyInWorld: (b2World *) w;
- (Ball *) ballWithDirection: (CGPoint) dir;
- (void) shoot;
- (void) makeActive;
- (void) moveWithDir: (CGPoint) direction andDistance: (int) dist;
- (void) moveWithPos:(CGPoint)position;
- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage;
- (void) doHitScore: (Ball *) ball;
- (void) doDestroyedScore: (Ball *) ball;
- (BOOL) isDead;
- (BOOL) doesCount;
- (BOOL) isBoss;
- (void) reset;
- (void) promote: (int) level;
- (void) removeArmor;
@end
