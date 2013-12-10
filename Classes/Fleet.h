//
//  Fleet.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/29/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invader.h"
#import "DynamicInvader.h"
#import "BeatSequencer.h"
#import "GameSettings.h"

#define MAX_NUKES 16

@interface Fleet : ContinuousBeatResponder {
	NSMutableArray *_invaders;
	DynamicInvader *_nukes[MAX_NUKES]; // referenecs not managed
	CGPoint _nukepos[MAX_NUKES];
	int _numNukes;
	float _lastShot;
	float _lastMovement;
	BOOL _shouldShoot;
}

@property (nonatomic, retain) NSMutableArray *invaders;
@property (nonatomic) float lastShot;
@property (nonatomic) float lastMovement;
@property (readwrite, assign) BOOL shouldShoot;
@property (readonly) DynamicInvader **nukes;
@property (readonly) CGPoint *nukepos;
@property (readonly) int numNukes;

- (void) shoot;
- (void) moveFleet;
- (void) removeInvader: (SpriteBody<Shooter> *) inv;
- (BOOL) isDead;
- (NSMutableArray *) getInvadersThatCount;

// doesn't actually add a nuke, just keeps track of the fact
// that this invader is a nuke, and where it is located
- (void) designateAsNuke: (DynamicInvader *) nuke at:(CGPoint) pos;
- (BOOL) vacantNuke;
- (CGPoint) vacantNukePos;
- (void) replaceNuke: (DynamicInvader *) nuke;

- (int) mostLeft;
- (int) mostRight;
- (int) highest;
- (int) lowest;

@end
