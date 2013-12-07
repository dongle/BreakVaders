//
//  BeatResponder.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BeatResponder
@required
- (BOOL) shouldRespondToBeat: (NSUInteger) beat;
- (BOOL) respondedToBeat: (NSUInteger) beat;
- (void) reset;
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time;
@optional
// beat with duration. All these must be overloaded to receive endBeat events
- (NSTimeInterval) startTimeForBeat: (NSUInteger) beat;
- (NSTimeInterval) endTimeForBeat: (NSUInteger) beat;
- (void) endBeat: (NSUInteger) beat atTime: (NSTimeInterval) time;
- (void) doTimer: (NSTimeInterval) dtime forBeat: (NSUInteger) beat;
- (BOOL) respondingToBeat: (NSUInteger) beat;
// continuous beat responder
- (void) introduce;
- (void) conclude;
@end

@interface BeatEvent : NSObject<BeatResponder>
{
	NSUInteger eventBeat;
	BOOL responded;
}
@property (readwrite, assign) NSUInteger eventBeat;

- (id) initOnBeat: (NSUInteger) beat;
- (BOOL) shouldRespondToBeat: (NSUInteger) beat;
- (BOOL) respondedToBeat: (NSUInteger) beat;
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time;

@end

@interface BeatEventWithDuration : BeatEvent
{
	NSTimeInterval startTime, endTime;
	BOOL started;
}
@property (readwrite, assign) NSTimeInterval startTime;
@property (readwrite, assign) NSTimeInterval endTime;

- (id) initOnBeat: (NSUInteger) beat starting: (NSTimeInterval) start ending: (NSTimeInterval) end;

- (BOOL) respondingToBeat: (NSUInteger) beat;
- (NSTimeInterval) startTimeForBeat: (NSUInteger) beat;
- (NSTimeInterval) endTimeForBeat: (NSUInteger) beat;

- (void) endBeat: (NSUInteger) beat atTime: (NSTimeInterval) time;
- (void) doTimer: (NSTimeInterval) dtime forBeat: (NSUInteger) beat;

@end

@interface ContinuousBeatResponder : NSObject<BeatResponder>
{
	NSInteger lastBeat;
}

@property (nonatomic, readonly) NSInteger lastBeat;

- (BOOL) shouldRespondToBeat: (NSUInteger) beat;
- (BOOL) respondedToBeat: (NSUInteger) beat;
- (void) reset;
- (void) doBeat: (NSUInteger) beat atTime: (NSTimeInterval) time;

@end

