//
//  PathBlockFleet.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BlockFleets.h"


@implementation PathBlockFleet

@end

@implementation DirBlockFleet
- (id) initWithConfig: (char *) config
			  andDims: (CGPoint) dims 
		  withSpacing: (CGFloat) space
			 atOrigin: (CGPoint) atorigin 
			 maxWidth: (int) width 
			  initDir: (CGPoint) dir
				 step: (CGFloat) s
			fromRight: (BOOL) fromright
			  playing: (NSString *) scoretoplay
		   difficulty: (int) level
{
	if ((self = [super initWithConfig:config andDims:dims withSpacing: space atOrigin:atorigin fromRight:fromright playing:scoretoplay difficulty:level])) 
	{
		direction = dir;
		step = s;
		maxWidth = width;
	}
	return self;
}
- (void) moveFleet {
	
	// check if invaders are still in fleet
	// check direction / boundaries
	// last: move
	
	// note step / iphone/ipad diffs
	
	if ([invaders count] == 0) return;
	
	//int newstep = step;
		
	// hack to not move invaders any more if they moved from way off screen
	
//	if (_IPAD) {
//		if ([self mostRight] > 800) {
//			newstep = 800;
//		}
//	}
//	else {
//		if ([self mostRight] > 350) {
//			newstep = 350;
//		}
//	}
	
	if ((direction.x > 0) && ([self mostRight] >= (origin.x - step + maxWidth / 2.0))) {
		direction = ccp(-1, 0);
	}
	else if ((direction.x < 0) && ([self mostLeft] <= (origin.x + step - maxWidth / 2.0))) {
		direction = ccp(1, 0);
	}
	if ((direction.y > 0) && ([self highest] >= (origin.y - step + maxWidth / 2.0))) {
		direction = ccp(0, -1);
	}
	else if ((direction.y < 0) && ([self lowest] <= (origin.y + step - maxWidth / 2.0))) {
		direction = ccp(0, 1);
	}
	
	
	for (Invader *invader in self.invaders) {
		[invader moveWithDir:direction andDistance: step];
	}
}

@end

@implementation CycleBlockFleet
- (id) initWithConfig: (char *) config
			  andDims: (CGPoint) dims 
		  withSpacing: (CGFloat) space
			 atOrigin: (CGPoint) atorigin 
			 cycleMap: (unsigned char *) cyclemap
			fromRight: (BOOL) fromright
			  playing: (NSString *) scoretoplay
		   difficulty: (int) level
{
	if ((self = [super initWithConfig:config andDims:dims withSpacing:space atOrigin:atorigin fromRight:fromright playing:scoretoplay difficulty:level])) 
	{
		memcpy(cycle, cyclemap, dims.x*dims.y);
		memset(positions, 0, dims.x*dims.y);
		int invIter = 0;
		for (int i=0; i<dims.x*dims.y; i++) {
			if (char2class(config[i])) {
				positions[0][i] = [invaders objectAtIndex:invIter++];
			}
		}
	}
	return self;
}

- (void) moveFleet {

	for (int i=0; i<dimensions.x*dimensions.y; i++) {
		SpriteBody<Shooter> *thing = positions[posBuf][i];
		if (thing && [thing isKindOfClass:[Invader class]] && (cycle[i] != i)) {
			CGPoint pos = ccp(origin.x - dimensions.x*spacing/2.0 + (cycle[i]%(int)dimensions.x)*spacing + spacing / 2.0,
							  origin.y + dimensions.y*spacing/2.0 - (cycle[i]/(int)dimensions.x)*spacing - spacing / 2.0);
			[(Invader *)thing moveWithPos:pos];
			positions[!posBuf][(int)cycle[i]] = positions[posBuf][i];
			positions[posBuf][i] = nil;
		}
	}
	
	posBuf = posBuf?0:1;
}

- (void) removeInvader:(SpriteBody <Shooter>*)inv {
	for (int i=0; i<dimensions.x*dimensions.y; i++) {
		if (positions[posBuf][i] == inv) 
			positions[posBuf][i] = nil;
		if (positions[!posBuf][i] == inv) 
			positions[!posBuf][i] = nil;
	}
	[super removeInvader:inv];
}

@end

