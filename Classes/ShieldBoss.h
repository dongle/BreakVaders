//
//  ShieldBoss.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/18/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invader.h"

@interface ShieldBoss : Invader {
	StaticSpriteBody *_shield;
}

@property (nonatomic, retain) StaticSpriteBody *shield;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w;
- (void) makePhysicalInWorld: (b2World *) world;
- (void) tick:(ccTime)dt;

@end
