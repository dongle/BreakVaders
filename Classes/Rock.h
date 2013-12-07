//
//  Rock.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/2/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticSpriteBody.h"
#import "Shooter.h"
#import "GameSettings.h"

@interface Rock : StaticSpriteBody<Shooter> {

}

+ (SpriteBody*) spriteBodyAt: (CGPoint) p withForce: (CGPoint) f inWorld: (b2World *) w;
- (void) createBodyInWorld: (b2World *) w;
- (void) makeActive;
- (void) moveWithDir: (CGPoint) dir andDistance: (int) dis;
@end
