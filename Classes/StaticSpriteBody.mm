//
//  StaticSpriteBody.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/30/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "StaticSpriteBody.h"
#import "ShieldBoss.h"
#import "PongVaderScene.h"

@implementation StaticSpriteBody


+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w {
	return nil;
}

-(void) tick: (ccTime)dt {
	
	CGPoint worldPos;
	
	if ([self.parent isKindOfClass:[SpriteBody class]]) {
		worldPos = ccp((self.position.x - self.parent.contentSize.width  / 2.0) + self.parent.position.x, 
					   (self.position.y - self.parent.contentSize.height / 2.0) + self.parent.position.y);
		//printf("shield coords: %5.2f, %5.2f \n", worldPos.x, worldPos.y);	
	}
	else {
		worldPos = ccp(self.position.x, self.position.y);
	}
	
	CGFloat x = worldPos.x / PTM_RATIO;
	CGFloat y = worldPos.y / PTM_RATIO;
	
	b2dBody->SetTransform(b2Vec2(x, y), 0);
	
//	if ([self isKindOfClass:[ShieldBoss class]]) {
//		printf("shieldboss coords: %5.2f, %5.2f \n", worldPos.x, worldPos.y);	
//	}
}

@end