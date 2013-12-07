//
//  BeatResponder.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BeatResponder.h"

@implementation BeatEvent
@synthesize eventBeat;
- (id) init {
	if ((self = [super init])) {
		eventBeat = 0;
		responded = NO;
	}
	return self;
}

- (id) initOnBeat: (NSUInteger) beat {
	if ((self = [super init])) {
		eventBeat = beat;
		responded = NO;
	}
	return self;
}

- (void) reset {
	responded = NO;
}

- (BOOL) shouldRespondToBeat: (NSUInteger) beat { return beat == eventBeat; }
- (BOOL) respondedToBeat: (NSUInteger) beat { return responded; }
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time { responded = YES; }

@end

@implementation BeatEventWithDuration
@synthesize startTime, endTime;
- (id) init {
	if ((self = [super init])) {
		startTime = 0;
		endTime = 0;
		started = NO;
	}
	return self;
}

- (id) initOnBeat: (NSUInteger) beat starting: (NSTimeInterval) start ending: (NSTimeInterval) end {
	if ((self = [super initOnBeat:beat])) {
		startTime = start;
		endTime = end;
		started = NO;
	}
	return self;
}

- (void) reset {
	started = NO;
	[super reset];
}

- (BOOL) respondingToBeat: (NSUInteger) beat { return started; }
- (NSTimeInterval) startTimeForBeat: (NSUInteger) beat { return startTime; }
- (NSTimeInterval) endTimeForBeat: (NSUInteger) beat { return endTime; }
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time { started = YES; }
- (void) endBeat: (NSUInteger) beat atTime: (NSTimeInterval) time { responded = YES; }
- (void) doTimer: (NSTimeInterval) dtime forBeat: (NSUInteger) beat {}

@end

@implementation ContinuousBeatResponder

@synthesize lastBeat;

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