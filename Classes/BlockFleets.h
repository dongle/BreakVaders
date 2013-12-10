//
//  PathBlockFleet.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockFleet.h"
#import "GameSettings.h"

#define MAXCYCLEBLOCKSIZE 256

@interface PathBlockFleet : BlockFleet {
}
@end

@interface DirBlockFleet : BlockFleet {
	float _maxWidth;
	CGPoint _direction;
	CGFloat _step;
}

- (id) initWithConfig: (char *) config
			  andDims: (CGPoint) dims 
		  withSpacing: (CGFloat) space
			 atOrigin: (CGPoint) atorigin 
			 maxWidth: (int) width 
			  initDir: (CGPoint) dir
				 step: (CGFloat) step
			fromRight: (BOOL) fromright
			  playing: (NSString *) scoretoplay
		   difficulty: (int) level;
@end

@interface CycleBlockFleet : BlockFleet {
	unsigned char _cycle[MAXCYCLEBLOCKSIZE];
	SpriteBody<Shooter> *_positions[2][MAXCYCLEBLOCKSIZE];
	int _posBuf;
}
- (id) initWithConfig: (char *) config
			  andDims: (CGPoint) dims 
		  withSpacing: (CGFloat) space
			 atOrigin: (CGPoint) atorigin 
			 cycleMap: (unsigned char *) cyclemap
			fromRight: (BOOL) fromright
			  playing: (NSString *) scoretoplay
		   difficulty: (int) level;
@end
