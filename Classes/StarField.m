//
//  StarField.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StarField.h"


@implementation StarField

+(StarField *) starField {
	return [[[StarField alloc] init] autorelease];
}

-(id) init {
	if ((self=[super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(winSize.width/2.0, winSize.height/2.0);
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"stars.png"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"stars.plist"];
		
		NSString *starList[] = {@"star1.png", @"star2.png", @"star3.png"};
		
		char probs[STARFIELD_DIVS][STARFIELD_DIVS][2];
		CGRect rects[STARFIELD_DIVS][STARFIELD_DIVS];
		CGSize rsize = CGSizeMake(STARFIELD_SIZE / STARFIELD_DIVS, STARFIELD_SIZE / STARFIELD_DIVS);
		
		for (int j=1; j<STARFIELD_DIVS; j++) for (int i=1; i<STARFIELD_DIVS; i++) {
			probs[i][j][0] = rand() % 10;
			probs[i][j][1] = rand() % 10;
		}

		for (int j=0; j<STARFIELD_DIVS; j++) for (int i=0; i<STARFIELD_DIVS; i++) {
			rects[i][j].size.width = rsize.width;
			rects[i][j].size.height = rsize.height;
			rects[i][j].origin.x = i*rsize.width;
			rects[i][j].origin.y = j*rsize.height;
		}
		
		for (int i=0; i<NUM_STARS; i++) {
			star[i] = [CCSprite spriteWithSpriteFrameName:starList[rand() % 3]];
			int e = 1, f = 1;
			for (int j=0; j < (int) log2(STARFIELD_DIVS); j++) {
				char *p = &probs[e][f][0];
				e = (rand() % 10 < p[0]) ? e * 2 : e * 2 + 1;
				f = (rand() % 10 < p[1]) ? f * 2 : f * 2 + 1;
			}
			e -= STARFIELD_DIVS;
			f -= STARFIELD_DIVS;
			CGRect bin = rects[e][f];
			star[i].position = ccp(bin.origin.x + rand() % (int) bin.size.width - STARFIELD_SIZE / 2.0 , 
								   bin.origin.y + rand() % (int) bin.size.height - STARFIELD_SIZE / 2.0);
			[sheet addChild:star[i]];
		}
		
		
		//star[0] = [CCSprite spriteWithSpriteFrameName:starList[2]];
		//[sheet addChild:star[0]];
		[self addChild:sheet];
		curTime = 0;
		driftTime = 0;
	}
	return self;
}

-(void) dealloc
{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[super dealloc];
}

- (void) doDrift {
	driftTime = curTime;
	float newwidth = STARFIELD_SIZE - COSMIC_DRIFT * 3;
	[self runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCScaleTo actionWithDuration:PLANET_SHAKE_DURATION scale:newwidth / STARFIELD_SIZE]]];
	[self runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCRotateBy actionWithDuration:PLANET_SHAKE_DURATION angle:-COSMIC_ROT_FACTOR]]];
}

- (void) reset {
	curTime = 0;
	driftTime = 0;
	[self runAction:
	 [CCEaseExponentialOut actionWithAction:
	  [CCScaleTo actionWithDuration:PLANET_SHAKE_DURATION scale:1]]];
}

//- (BOOL) shouldRespondToBeat:(NSUInteger)beat { return (beat % 2) == 1;}
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{

	for (int i=0; i<NUM_STARS; i++) {
		if ((beat % 2) == 0)
			star[i].scale = 1.3;
		else 
			star[i].scale = 1;

		
//		[self runAction:
//		 [CCEaseOut actionWithAction:
//		  [CCScaleTo actionWithDuration:0.2 scale:1]]];
//		
	}
}

- (void) tick: (ccTime) dt {
	curTime += dt;
	self.rotation -= dt * M_PI/COSMIC_ROT_FACTOR;
	if (curTime > (driftTime + PLANET_SHAKE_DURATION)) self.scale = (self.scale*149 + 1.0) / 150.0;
}

@end
