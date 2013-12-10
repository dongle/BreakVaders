//
//  Powerup.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/4/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteBody.h"
#import "GameSettings.h"
#import "Ball.h"

@interface Powerup : SpriteBody {
	int _state;
	int _health;
}

@property (readwrite, assign) int state;
@property (readwrite, assign) int health;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withEffect: (int) e withForce: (CGPoint) f inWorld: (b2World *) w;
- (BOOL) doKill;
- (BOOL) isDead;
- (void) doHitFrom: (Ball *) ball withDamage: (int) d;

@end
