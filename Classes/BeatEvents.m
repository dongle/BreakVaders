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
		responder = [resp retain];
		sequencer = [seq retain];
	}
	return self;
}

- (void) dealloc {
	[responder release];
	[sequencer release];
	[super dealloc];
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	[sequencer addResponder:responder];
	responded = YES;
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
		responder = [resp retain];
		sequencer = [seq retain];
	}
	return self;
}

- (void) dealloc {
	[responder release];
	[sequencer release];
	[super dealloc];
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	[sequencer removeResponder:responder];
	responded = YES;
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
		nextState = [state retain];
		nextTime = time;
	}
	return self;
}

- (void) dealloc {
	[nextState release];
	[super dealloc];
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	[[GameState getCurrentState] changeTo:nextState after:nextTime];
	responded = YES;
}

@end

