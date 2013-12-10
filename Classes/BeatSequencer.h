//
//  BeatSequencer.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "BeatResponder.h"

#define MAX_AHEAD_BEATS  4
#define MAX_ASTERN_BEATS 4
#define FIRSTPLAYDELAY 0.3
#define PLAYDELAY 0.3

@interface BeatSequencer : NSObject <BeatResponder> {
	NSMutableArray __weak **_sequence;
    NSMutableArray *_responders;
	NSTimeInterval _timeElapsed, _songTime;
	CGFloat _bpmin;
	int _seqCapacity;
	
	// used to delay song start to sync with graphics
	BOOL _firstPlay, _songPlaying, _isPaused;
	NSString *_songToPlay;
	CGFloat _songShift;
}

@property (readonly) CGFloat bpmin;

+ (BeatSequencer *) getInstance;
+ (void) cleanup;

- (void) addEvent: (BeatEvent *) event;
- (void) addEvents: (int) numObjects, ...;
- (void) clearEvents;
- (void) reset;

- (void) addResponder: (NSObject<BeatResponder> *) responder;
- (void) removeResponder: (NSObject<BeatResponder> *) responder;
- (void) clearResponders;

// StartWithSong: requires song to already be loaded by SimpleAudioEngine
- (void) startWithSong: (NSString *) songPath andBPM: (CGFloat) bpm shifted: (CGFloat) shift;
- (void) end;
- (void) doTimer: (NSTimeInterval) dtime;

- (void) pause;
- (void) unpause;

@end