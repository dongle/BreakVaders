/*
 *  Shooter.h
 *  MultiBreakout
 *
 *  Created by Cole Krumbholz on 7/21/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import "Ball.h"

@protocol Shooter
- (void) makeActive;
- (Ball *) ballWithDirection: (CGPoint) dir;
- (void) shoot;
- (BOOL) doHitFrom: (Ball *) ball withDamage: (int) damage;
- (void) doHitScore: (Ball *) ball;
- (void) doDestroyedScore: (Ball *) ball;	
- (BOOL) isDead;
- (BOOL) isBoss;
- (BOOL) doesCount;
- (void) reset;
- (void) promote: (int) level;
@end