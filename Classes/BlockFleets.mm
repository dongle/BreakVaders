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
		_direction = dir;
		_step = s;
		_maxWidth = width;
	}
	return self;
}
- (void) moveFleet {
	
	// check if invaders are still in fleet
	// check direction / boundaries
	// last: move
	
	// note step / iphone/ipad diffs
	
	if ([_invaders count] == 0) return;
	
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
	
	if ((_direction.x > 0) && ([self mostRight] >= (_origin.x - _step + _maxWidth / 2.0))) {
		_direction = ccp(-1, 0);
	}
	else if ((_direction.x < 0) && ([self mostLeft] <= (_origin.x + _step - _maxWidth / 2.0))) {
		_direction = ccp(1, 0);
	}
	if ((_direction.y > 0) && ([self highest] >= (_origin.y - _step + _maxWidth / 2.0))) {
		_direction = ccp(0, -1);
	}
	else if ((_direction.y < 0) && ([self lowest] <= (_origin.y + _step - _maxWidth / 2.0))) {
		_direction = ccp(0, 1);
	}
	
	
	for (Invader *invader in self.invaders) {
		[invader moveWithDir:_direction andDistance: _step];
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
		memcpy(_cycle, cyclemap, dims.x*dims.y);
		memset(_positions, 0, dims.x*dims.y);
		int invIter = 0;
		for (int i=0; i<dims.x*dims.y; i++) {
			if (char2class(config[i])) {
				_positions[0][i] = [_invaders objectAtIndex:invIter++];
			}
		}
	}
	return self;
}

- (void) moveFleet {

	for (int i=0; i<_dimensions.x*_dimensions.y; i++) {
		SpriteBody<Shooter> *thing = _positions[_posBuf][i];
		if (thing && [thing isKindOfClass:[Invader class]] && (_cycle[i] != i)) {
			CGPoint pos = ccp(_origin.x - _dimensions.x*_spacing/2.0 + (_cycle[i]%(int)_dimensions.x)*_spacing + _spacing / 2.0,
							  _origin.y + _dimensions.y*_spacing/2.0 - (_cycle[i]/(int)_dimensions.x)*_spacing - _spacing / 2.0);
			[(Invader *)thing moveWithPos:pos];
			_positions[!_posBuf][(int)_cycle[i]] = _positions[_posBuf][i];
			_positions[_posBuf][i] = nil;
		}
	}
	
	_posBuf = _posBuf?0:1;
}

- (void) removeInvader:(SpriteBody <Shooter>*)inv {
	for (int i=0; i<_dimensions.x*_dimensions.y; i++) {
		if (_positions[_posBuf][i] == inv)
			_positions[_posBuf][i] = nil;
		if (_positions[!_posBuf][i] == inv)
			_positions[!_posBuf][i] = nil;
	}
	[super removeInvader:inv];
}

@end

