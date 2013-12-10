//
//  BeatNode.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BeatNode.h"


@implementation BeatNode

- (id) init {
	if ((self = [super init])) {
		_lastBeat = -1;
	}
	return self;
}

- (BOOL) shouldRespondToBeat: (NSUInteger) beat { return YES; }
- (BOOL) respondedToBeat: (NSUInteger) beat { return (((NSInteger) beat) <= _lastBeat); }
- (void) reset { _lastBeat = -1; }
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time { _lastBeat = beat; }


@end
