//
//  Ball.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteBody.h"
#import "Player.h"
#import "GameSettings.h"

#define BALL_RADIUS  8
#define BALL_RADIUS_PHN  4

@interface Bounce : NSObject
{
	CGPoint pos;
	id hit;
}
@property (readwrite, assign) CGPoint pos;
@property (readwrite, assign) id hit;
- (id) initWithPos: (CGPoint) p hit: (id) h;
+ (id) bounceWithPos: (CGPoint) p hit: (id)h;
@end

@interface Ball : SpriteBody {
	NSObject *lastHit;
	Player *lastPlayer;
	int health, combo, volley;
	BOOL isFireball, isBulletTime, isNuke;
	CCMotionStreak *streak;
	float AIOffset; // computer paddle will always hit this ball at the same angle
	float strobeTime;
	NSMutableArray *bounces;
	CCRibbon *ribbon;
}

@property (readwrite, assign) Player * lastPlayer;  // weak ref
@property (readwrite, assign) int health, combo, volley;
@property (readwrite, assign) BOOL isBulletTime;
@property (readwrite, assign) float AIOffset;
@property (readwrite, assign) float strobeTime;
@property (readwrite, assign) BOOL isNuke; // used to keep track of ball data for dynamic invaders
@property (nonatomic, retain) NSMutableArray *bounces;
@property (nonatomic, retain) CCRibbon *ribbon;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) world;
- (BOOL) doHit: (NSObject *) hitwhat;
- (BOOL) doKill;
- (BOOL) isDead;
- (BOOL) isHot;
- (BOOL) isWhite;
- (void) makeFireball;
- (void) increaseCombo;
- (void) resetCombo;
- (void) enterBulletTime;
- (void) exitBulletTime;
- (void) strobe: (float) time;
- (void) addBounceAgainst: (id) thing;
- (void) updateRibbon: (ccTime) dt;
- (void) cleanup;

- (void) doHitFrom: (Ball *) ball withDamage: (int) d;
@end
