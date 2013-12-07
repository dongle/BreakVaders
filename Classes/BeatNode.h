//
//  BeatNode.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BeatResponder.h"

// this is a convenience class that implements the same functionality as
// ContinuousBeatResponder on a CCNode

@interface BeatNode : CCNode <BeatResponder> {
	NSInteger lastBeat;
}

- (BOOL) shouldRespondToBeat: (NSUInteger) beat;
- (BOOL) respondedToBeat: (NSUInteger) beat;
- (void) reset;
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time;

@end
