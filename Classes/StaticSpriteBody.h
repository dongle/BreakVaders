//
//  StaticSpriteBody.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/30/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteBody.h"

@interface StaticSpriteBody : SpriteBody {

}

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w;

-(void) tick: (ccTime) dt;

@end
