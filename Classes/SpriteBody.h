//
//  SpriteBody.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#define PTM_RATIO 32.0

@interface SpriteBody : CCSprite {
	@public
	b2Body *_b2dBody;
	b2World *_world;
	CCAnimation *_idle, *_armored, *_pop;
	float _baseScale;
}

@property (readwrite, assign) b2Body *b2dBody;
@property (readwrite, assign) b2World *world;
@property (readwrite, assign) float baseScale;
@property (nonatomic, retain) CCAnimation *idle;
@property (nonatomic, retain) CCAnimation *armored;
@property (nonatomic, retain) CCAnimation *pop;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w;

-(void) tick: (ccTime) dt;
-(CGRect) getRect;
- (void) reset;
- (BOOL) doHit;
- (void) cleanupSpriteBody;
- (CGPoint) getDir;

@end
