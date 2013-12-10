//
//  BeatResponder.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BeatResponder.h"

@implementation BeatEvent

@synthesize eventBeat = _eventBeat;

- (id) init {
	if ((self = [super init])) {
		_eventBeat = 0;
		_responded = NO;
	}
	return self;
}

- (id) initOnBeat: (NSUInteger) beat {
	if ((self = [super init])) {
		_eventBeat = beat;
		_responded = NO;
	}
	return self;
}

- (void) reset {
	_responded = NO;
}

- (BOOL) shouldRespondToBeat: (NSUInteger) beat { return beat == _eventBeat; }
- (BOOL) respondedToBeat: (NSUInteger) beat { return _responded; }
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time { _responded = YES; }

@end

@implementation BeatEventWithDuration

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

- (id) init {
	if ((self = [super init])) {
		_startTime = 0;
		_endTime = 0;
		_started = NO;
	}
	return self;
}

- (id) initOnBeat: (NSUInteger) beat starting: (NSTimeInterval) start ending: (NSTimeInterval) end {
	if ((self = [super initOnBeat:beat])) {
		_startTime = start;
		_endTime = end;
		_started = NO;
	}
	return self;
}

- (void) reset {
	_started = NO;
	[super reset];
}

- (BOOL) respondingToBeat: (NSUInteger) beat { return _started; }
- (NSTimeInterval) startTimeForBeat: (NSUInteger) beat { return _startTime; }
- (NSTimeInterval) endTimeForBeat: (NSUInteger) beat { return _endTime; }
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time { _started = YES; }
- (void) endBeat: (NSUInteger) beat atTime: (NSTimeInterval) time { _responded = YES; }
- (void) doTimer: (NSTimeInterval) dtime forBeat: (NSUInteger) beat {}

@end

@implementation ContinuousBeatResponder

@synthesize lastBeat = _lastBeat;

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