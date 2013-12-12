//
//  BeatSequencer.m
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BeatSequencer.h"
#import "SimpleAudioEngine.h"

#define SECSPERBEAT (60 / _bpmin)

@implementation BeatSequencer

@synthesize bpmin = _bpmin;

static BeatSequencer *__bs = nil;

+ (BeatSequencer *) getInstance {
	if (__bs == nil)
		__bs = [[BeatSequencer alloc] init];
	return __bs;
}

+ (void) cleanup {
	[__bs release];
	__bs = nil;
}

- (id) init {
	if ((self = [super init])) {
		_seqCapacity = 4*4*20;
		_sequence = malloc(sizeof(NSMutableArray *) * _seqCapacity);
		memset(_sequence, 0, sizeof(NSMutableArray *) * _seqCapacity);
		_responders = [[NSMutableArray array] retain];
		[_responders addObject:self];
		_timeElapsed = _songTime = 0;
		_bpmin = 100;
		_firstPlay = YES;
		_songPlaying = NO;
		_songShift = 0;
	}
	return self;
}

- (void) dealloc {
	for (int i=0; i<_seqCapacity; i++) {
		[_sequence[i] release];
	}
	free(_sequence);
	[_responders release];
	[_songToPlay release];
	[super dealloc];
}

- (void) _incSequence {
	int newCapacity = _seqCapacity * 2;
	NSMutableArray **newSeq = malloc(sizeof(NSMutableArray *) * newCapacity);
	memset(newSeq, 0, sizeof(NSMutableArray *) * newCapacity);
	memcpy(newSeq, _sequence, sizeof(NSMutableArray *) * _seqCapacity);
	free(_sequence);
	_sequence = newSeq;
	_seqCapacity = newCapacity;
}

- (void) addEvent: (BeatEvent *) event 
{
	NSMutableArray *array;
	while (_seqCapacity <= event.eventBeat) [self _incSequence];
	if (!(array = _sequence[event.eventBeat])) {
		array = [NSMutableArray arrayWithCapacity:4];
		_sequence[event.eventBeat] = [array retain];
	}
	[array addObject:event];
}

- (void) addEvents: (int) numObjects, ...
{	
	if (numObjects > 0) {
		BeatEvent *eachObject;
		va_list argumentList;
		va_start(argumentList, numObjects);
		while (numObjects > 0) 
		{
			eachObject = va_arg(argumentList, BeatEvent *);
			if ([eachObject isKindOfClass:[BeatEvent class]])
				[self addEvent: eachObject];  
            else {
				NSLog(@"Invalid object passed to addEvents. (expects two or more BeatEvent instances. If you are only passing one BeatEvent, use addEvent:)");
				break;
			}
			numObjects--;
		}
		va_end(argumentList);
	}
}

- (void) clearEvents {
	for (int i=0; i<_seqCapacity; i++) {
		[_sequence[i] release];
	}
	free(_sequence);
	_seqCapacity = 4*4*20;
	_sequence = malloc(sizeof(NSMutableArray *) * _seqCapacity);
	memset(_sequence, 0, sizeof(NSMutableArray *) * _seqCapacity);
}

- (void) reset {
	for (int i=0; i<_seqCapacity; i++) {
		for (BeatEvent *event in _sequence[i]) {
			[event reset];
		}
	}
	_timeElapsed = 0;
	_songTime = 0;
}

- (void) addResponder: (NSObject<BeatResponder> *) responder {
    dispatch_async(dispatch_get_main_queue(),
                   ^{
        [_responders addObject:responder];
                   }
                   );
}

- (void) removeResponder: (NSObject<BeatResponder> *) responder {
	[_responders removeObject:responder];
}

- (void) clearResponders {
	[_responders removeAllObjects];
	[_responders addObject:self];
}

- (void) startWithSong: (NSString *) songPath andBPM: (CGFloat) bpm shifted: (CGFloat) shift
{
	[_songToPlay autorelease];
	_songToPlay = [songPath retain];
	
	NSTimeInterval delay = _firstPlay ? FIRSTPLAYDELAY : PLAYDELAY;
	if (delay<=0) {
		[SimpleAudioEngine sharedEngine].backgroundMusicVolume = 1.0;
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:_songToPlay];
		_songPlaying = YES;
	}
	_bpmin = bpm;
	_songShift = shift;
}

- (void) end 
{
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	_firstPlay = NO;
	_songPlaying = NO;
}

- (void) doTimer: (NSTimeInterval) dtime 
{
	if (_isPaused) {
		return;
	}
	
	_timeElapsed += dtime;
	

	NSTimeInterval delay = _firstPlay ? FIRSTPLAYDELAY : PLAYDELAY;
	//printf("%5.2f %5.2f\n", _timeElapsed, delay);
	if ((delay>0) && !_songPlaying && (_timeElapsed > delay)) {
		[SimpleAudioEngine sharedEngine].backgroundMusicVolume = 1.0;
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:_songToPlay];
		_songPlaying = YES;
	} else if (_timeElapsed <= -delay) {
		return;
	}	
	_songTime = _timeElapsed - delay;
	_songTime += _songShift;
	
	int nextBeat = floor(_songTime / SECSPERBEAT);
	//printf("%5.2f %6.3f %d\n", songTime, songTime / SECSPERBEAT, nextBeat);
	
	for (int i=(nextBeat-MAX_ASTERN_BEATS) < 0 ? 0 : nextBeat-MAX_ASTERN_BEATS; i < nextBeat+MAX_AHEAD_BEATS; i++) {
		for (NSObject<BeatResponder> *responder in _responders) {
			BOOL shouldRespond = [responder shouldRespondToBeat: i];
			BOOL responded = [responder respondedToBeat:i];
			if (shouldRespond && !responded) {

				if ([responder respondsToSelector: @selector(respondingToBeat:)] && 
					[responder respondsToSelector: @selector(endBeat:atTime:)] && 
					[responder respondsToSelector: @selector(startTimeForBeat:)] && 
					[responder respondsToSelector: @selector(endTimeForBeat:)]) 
				{

					if ((i*SECSPERBEAT < _songTime) ||
						((i*SECSPERBEAT+[responder startTimeForBeat:i]) < _songTime))
					{
						if ([responder respondingToBeat:i]) {
							// do timer
							if ([responder respondsToSelector: @selector(doTimer:forBeat:)])
								[responder doTimer:dtime forBeat:i];
						} else if (i >= nextBeat) { 
							[responder doBeat:i atTime:_songTime];
						}
						
						// end beat if appropriate
						if ((([responder respondingToBeat:i]) || (i == nextBeat)) && 
							((i*SECSPERBEAT+[responder endTimeForBeat:i]) < _songTime))
						{
							[responder endBeat:i atTime:_songTime];
						}			
					}
				} else if ((i*SECSPERBEAT < _songTime) && (i == nextBeat))
					[responder doBeat:i atTime:_songTime];
					
			}
		}
	}
			
}

- (BOOL) shouldRespondToBeat: (NSUInteger) beat 
{
	if (beat >= _seqCapacity) return NO;
	return (_sequence[beat] != nil);
	/*
	NSUInteger i = 0;
	BeatEvent *event = [sequence objectAtIndex:i];
	while (event && ![event shouldRespondToBeat:beat]) event = [sequence objectAtIndex:++i];
	return (event != nil);
	 */
}

- (BOOL) respondingToBeat: (NSUInteger) beat 
{
	if (beat >= _seqCapacity) return NO;
	for (BeatEvent *event in _sequence[beat]) {
		if ([event respondsToSelector:@selector(respondingToBeat:)] && 
			[event respondingToBeat:beat]) return YES;
	}
	return NO;
	
	/*
	for (BeatEvent *event in started) {
		if ([event respondingToBeat: beat]) return YES;
	}
	return NO;
	 */
}

- (BOOL) respondedToBeat: (NSUInteger) beat 
{
	if (beat >= _seqCapacity) return NO;
	NSArray *array = _sequence[beat];
	BOOL shouldRespond = (array != nil);
	for (BeatEvent *event in array) {
		if (![event respondedToBeat:beat]) return NO;
	}
	return shouldRespond;

	/*
	for (BeatEvent *event in started) {
		if ([event respondingToBeat: beat]) return NO;
	}
	return YES;
	 */
}

- (NSTimeInterval) startTimeForBeat: (NSUInteger) beat 
{
	if (beat >= _seqCapacity) return 0;
	NSTimeInterval startTime = INFINITY;
	for (BeatEvent *event in _sequence[beat]) {
		if ([event respondsToSelector:@selector(startTimeForBeat:)]) {
			NSTimeInterval beatStart = [event startTimeForBeat:beat];
			if (beatStart < startTime) startTime = beatStart;
		} else {
			if (0 < startTime) startTime = 0;
		}
	}
	return startTime;

	/*
	NSUInteger i = 0;
	BeatEvent *event = [sequence objectAtIndex:i];
	while (event && ![event shouldRespondToBeat:beat]) event = [sequence objectAtIndex:++i];
	if ([event respondsToSelector:@selector(startTimeForBeat:)])
		return [event startTimeForBeat: beat];
	else return 0;
	 */
}

- (NSTimeInterval) endTimeForBeat: (NSUInteger) beat 
{
	if (beat >= _seqCapacity) return 0;
	NSTimeInterval endTime = -INFINITY;
	for (BeatEvent *event in _sequence[beat]) {
		if ([event respondsToSelector:@selector(endTimeForBeat:)]) {
			NSTimeInterval beatEnd = [event endTimeForBeat:beat];
			if (beatEnd > endTime) endTime = beatEnd;
		} else {
			if (0 > endTime) endTime = 0;
		}
	}
	return endTime;
	
	/*
	NSUInteger i = 0;
	BeatEvent *event = [sequence objectAtIndex:i];
	while (event && ![event shouldRespondToBeat:beat]) event = [sequence objectAtIndex:++i];
	while (event && [event shouldRespondToBeat:beat]) {
		if ([event respondsToSelector:@selector(endTimeForBeat:)]) {
			NSTimeInterval beatEnd = [event endTimeForBeat:beat];
			if (beatEnd > endTime) endTime = beatEnd;
		} else {
			if (0 > endTime) endTime = 0;
		}
		event = [sequence objectAtIndex:++i];
	}
	return endTime;
	 */
}

- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	if (beat >= _seqCapacity) return;
	for (BeatEvent *event in _sequence[beat]) {
		if ([event respondsToSelector:@selector(startTimeForBeat:)]) 
		{
			if ((time > (beat*SECSPERBEAT+[event startTimeForBeat:beat]))) 
			{
				[event doBeat:beat atTime:time];
			}
		}
		else if (time > (beat *SECSPERBEAT))
		{
			[event doBeat: beat atTime:time];
		}
	}

	/*
	
	NSObject<BeatResponder> *event = [sequence objectAtIndex:curEvent];
	
	while (event && [event respondsToBeat:beat] && ((beat*SECSPERBEAT + ([event durationForBeat:beat] < 0 ? [event durationForBeat:beat] : 0)) <= timeElapsed)) 
	{
		[event doBeatAtTime:timeElapsed];
		event = [sequence objectAtIndex:++curEvent];
	}
	 */
	
}

- (void) endBeat: (NSUInteger) beat atTime: (NSTimeInterval) time 
{
	if (beat >= _seqCapacity) return;
	for (BeatEvent *event in _sequence[beat]) {
		if ([event respondsToSelector:@selector(endBeat:atTime:)]) 
		{
			[event endBeat:beat atTime:time];
		}
	}	
}

- (void) doTimer: (NSTimeInterval) dtime forBeat: (NSUInteger) beat
{
	if (beat >= _seqCapacity) return;
	for (BeatEvent *event in _sequence[beat]) {
		if (![event respondedToBeat:beat]) {
			if ([event respondsToSelector: @selector(respondingToBeat:)] && 
				[event respondsToSelector: @selector(endBeat:atTime:)] && 
				[event respondsToSelector: @selector(startTimeForBeat:)] && 
				[event respondsToSelector: @selector(endTimeForBeat:)]) 
			{
				if ((beat*SECSPERBEAT < _songTime) ||
					((beat*SECSPERBEAT+[event startTimeForBeat:beat]) < _songTime))
				{
					if ([event respondingToBeat:beat]) {
						if ([event respondsToSelector: @selector(doTimer:forBeat:)])
							[event doTimer:dtime forBeat:beat];
					} else { 
						[event doBeat:beat atTime:_songTime];
					}
					if ((beat*SECSPERBEAT+[event endTimeForBeat:beat]) < _songTime)
						[event endBeat:beat atTime:_songTime];
				}
			} else if (beat*SECSPERBEAT < _songTime)
				[event doBeat:beat atTime:_songTime];
		}
	}
}

- (void) pause {
	_isPaused = YES;
	[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

- (void) unpause {
	_isPaused = NO;
	[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

@end
