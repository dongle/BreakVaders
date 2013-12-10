//
//  SpriteBody.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "SpriteBody.h"

@interface SpriteBody ()

@end

@implementation SpriteBody
@synthesize b2dBody = _b2dBody;
@synthesize world = _world;
@synthesize idle = _idle;
@synthesize armored = _armored;
@synthesize pop = _pop;
@synthesize baseScale = _baseScale;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	return nil;
}

-(void) dealloc {
	[_idle release];
	[_armored release];
	[_pop release];
	[super dealloc];
}

-(void) tick: (ccTime)dt {	
	// sync CC2D w/ Box2D
	self.position = ccp(_b2dBody->GetPosition().x * PTM_RATIO,
						_b2dBody->GetPosition().y * PTM_RATIO);
	self.rotation = -1 * CC_RADIANS_TO_DEGREES(_b2dBody->GetAngle());
}

-(CGRect) getRect {
	return CGRectMake(self.position.x - (self.contentSize.width/2.0),
					  self.position.y - (self.contentSize.height/2.0),
					  self.contentSize.width, self.contentSize.height);
}

- (void) reset {}
- (void) cleanupSpriteBody {}

- (BOOL) doHit { return YES; }

- (CGPoint) getDir {
	if (!_b2dBody) return ccp(0,0);
	b2Vec2 vec = _b2dBody->GetLinearVelocity();
	vec.Normalize();
	return ccp(vec.x, vec.y);
}

@end
