//
//  UFO.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UFO.h"
#include "GameSettings.h"

@implementation UFO

@synthesize enterAnim = _enterAnim;
@synthesize releaseAnim = _releaseAnim;
@synthesize leaveAnim = _leaveAnim;
@synthesize mynuke = _mynuke;

-(id) initUFO {
	if ((self = [super initWithSpriteFrameName:@"ufo_closed1.png"])) {

		NSMutableArray *animFrames = [NSMutableArray array];
		for (int i=1; i<=4; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"ufo_closed%d.png", i]];
			[frame.texture setAliasTexParameters];
			[animFrames addObject:frame];		
		}
		
		if (_IPAD) {
			self.scale = 2.0;
		}
		
		self.enterAnim = [CCAnimation animationWithSpriteFrames:animFrames delay:GAME_SPB/3.0f];
		
		animFrames = [NSMutableArray array];
		for (int i=1; i<=4; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"ufo_open%d.png", i]];
			[frame.texture setAliasTexParameters];
			[animFrames addObject:frame];		
		}
		self.leaveAnim = [CCAnimation animationWithSpriteFrames:animFrames delay:GAME_SPB/3.0f];
		
		animFrames = [NSMutableArray array];
		for (int i=1; i<=4; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"ufo_release%d.png", i]];
			[frame.texture setAliasTexParameters];
			[animFrames addObject:frame];		
		}
		self.releaseAnim = [CCAnimation animationWithSpriteFrames:animFrames delay:GAME_SPB/3.0f];
		
		[self runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:self.enterAnim restoreOriginalFrame:NO] ]];

	}
	return self;
}

- (void) dealloc {
	[_enterAnim release];
	[_leaveAnim release];
	[_releaseAnim release];
	[_mynuke release];
	[super dealloc];
}

- (void) drop {
	[_mynuke makeActive];
	[self runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:self.leaveAnim restoreOriginalFrame:NO] ]];
}

- (void) die {
	[self.parent removeChild:self cleanup:YES];
}

- (void) flyTo: (CGPoint) pos with: (DynamicInvader *) nuke 
{
	CGSize ssz = [CCDirector sharedDirector].winSize;
	float from = pos.x<(ssz.width/2.0)?-100:ssz.width+100;
	float to   = pos.x<(ssz.width/2.0)?ssz.width+100:-100;

	nuke.position = ccp(from, pos.y);
	[nuke runAction: [CCMoveTo actionWithDuration:2 position:pos]];
	self.mynuke = nuke;
	
	if (_IPAD) {
	self.mynuke.scale = 2.0;
	self.mynuke.baseScale = 2.0;
	}

	BOOL top = pos.y>ssz.height/2.0;
	int offset = top?-8:8;

	self.rotation = top?180:0;
	self.position = ccp(from, pos.y+offset);

	id action1 = [CCMoveTo actionWithDuration:2 position:ccp(pos.x, pos.y+offset)];
	id action2 = [CCAnimate actionWithAnimation:self.releaseAnim restoreOriginalFrame:NO];
	id action3 = [CCMoveTo actionWithDuration:2  position: ccp(to,pos.y+offset)];
	[self runAction: [CCSequence actions:action1, action2, 
					  [CCCallFuncN actionWithTarget:self selector:@selector(drop)], action3, 
					  [CCCallFuncN actionWithTarget:self selector:@selector(die)], nil]];
}

@end
