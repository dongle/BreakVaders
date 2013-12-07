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
		lastBeat = -1;
	}
	return self;
}

- (BOOL) shouldRespondToBeat: (NSUInteger) beat { return YES; }
- (BOOL) respondedToBeat: (NSUInteger) beat { return (((NSInteger) beat) <= lastBeat); }
- (void) reset { lastBeat = -1; }
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time { lastBeat = beat; }


@end
