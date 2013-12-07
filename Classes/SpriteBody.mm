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
@synthesize b2dBody, world, idle, armored, pop, baseScale;

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	return nil;
}

-(void) dealloc {
	[idle release];
	[armored release];
	[pop release];
	[super dealloc];
}

-(void) tick: (ccTime)dt {	
	// sync CC2D w/ Box2D
	self.position = ccp(b2dBody->GetPosition().x * PTM_RATIO,
						b2dBody->GetPosition().y * PTM_RATIO);
	self.rotation = -1 * CC_RADIANS_TO_DEGREES(b2dBody->GetAngle());
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
	if (!b2dBody) return ccp(0,0);
	b2Vec2 vec = b2dBody->GetLinearVelocity();
	vec.Normalize();
	return ccp(vec.x, vec.y);
}

@end
