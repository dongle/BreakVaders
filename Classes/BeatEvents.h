//
//  BeatEvents.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeatSequencer.h"
#import "GameState.h"


@interface AddBeatResponderEvent : BeatEvent {
	NSObject<BeatResponder> *_responder;
	BeatSequencer *_sequencer;
}
+ (id) eventOnBeat: (NSUInteger) beat withResponder: (NSObject<BeatResponder> *) resp andSequencer: (BeatSequencer *) seq;
- (id) initOnBeat: (NSUInteger) beat withResponder: (NSObject<BeatResponder> *) resp andSequencer: (BeatSequencer *) seq;
@end

@interface RemoveBeatResponderEvent : BeatEvent {
	NSObject<BeatResponder> *_responder;
	BeatSequencer *_sequencer;
}
+ (id) eventOnBeat: (NSUInteger) beat withResponder: (NSObject<BeatResponder> *) resp andSequencer: (BeatSequencer *) seq;
- (id) initOnBeat: (NSUInteger) beat withResponder: (NSObject<BeatResponder> *) resp andSequencer: (BeatSequencer *) seq;
@end

@interface ChangeStateEvent : BeatEvent {
	GameState *_nextState;
	NSTimeInterval _nextTime;
}
+ (id) eventOnBeat: (NSUInteger) beat to: (GameState *) state after: (NSTimeInterval) time;
- (id) initOnBeat: (NSUInteger) beat to: (GameState *) state after: (NSTimeInterval) time; 
@end

