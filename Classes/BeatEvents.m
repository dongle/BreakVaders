//
//  BeatEvents.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BeatEvents.h"

@implementation AddBeatResponderEvent 

+ (id) eventOnBeat: (NSUInteger) beat withResponder: (NSObject<BeatResponder> *) resp andSequencer: (BeatSequencer *) seq
{
	return [[[AddBeatResponderEvent alloc] initOnBeat: beat withResponder: resp andSequencer: seq] autorelease];
}

- (id) initOnBeat: (NSUInteger) beat withResponder: (NSObject<BeatResponder> *) resp andSequencer: (BeatSequencer *) seq
{
	if ((self = [super initOnBeat:beat])) {
		_responder = [resp retain];
		_sequencer = [seq retain];
	}
	return self;
}

- (void) dealloc {
	[_responder release];
	[_sequencer release];
	[super dealloc];
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	[_sequencer addResponder:_responder];
	_responded = YES;
}

@end

@implementation RemoveBeatResponderEvent

+ (id) eventOnBeat: (NSUInteger) beat withResponder: (NSObject<BeatResponder> *) resp andSequencer: (BeatSequencer *) seq
{
	return [[[RemoveBeatResponderEvent alloc] initOnBeat: beat withResponder: resp andSequencer: seq] autorelease];
}

- (id) initOnBeat: (NSUInteger) beat withResponder: (NSObject<BeatResponder> *) resp andSequencer: (BeatSequencer *) seq
{
	if ((self = [super initOnBeat:beat])) {
		_responder = [resp retain];
		_sequencer = [seq retain];
	}
	return self;
}

- (void) dealloc {
	[_responder release];
	[_sequencer release];
	[super dealloc];
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	[_sequencer removeResponder:_responder];
	_responded = YES;
}

@end

@implementation ChangeStateEvent

+ (id) eventOnBeat: (NSUInteger) beat to: (GameState *) state after: (NSTimeInterval) time 
{
	return [[[ChangeStateEvent alloc] initOnBeat: beat to:state after:time] autorelease];
}

- (id) initOnBeat: (NSUInteger) beat to: (GameState *) state after: (NSTimeInterval) time 
{
	if ((self = [super initOnBeat:beat])) {
		_nextState = [state retain];
		_nextTime = time;
	}
	return self;
}

- (void) dealloc {
	[_nextState release];
	[super dealloc];
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	[[GameState getCurrentState] changeTo:_nextState after:_nextTime];
	_responded = YES;
}

@end

