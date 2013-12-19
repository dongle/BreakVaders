//
//  GameState.h
//  Toe2Toe
//
//  Created by Cole Krumbholz on 10/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

//@protocol StateHandling
//@optional 
//- (void) enter;
//- (void) leave;
//- (State *) doTimer: (CFTimeInterval) dTime;
//- (State *) doTap: (CGPoint) location;
//@end

// State 

#define kSTATE_NO_CLOSE_DATA	0
#define kSTATE_CLOSE_DATA		1
#define kSTATE_CLOSE_DATA_QUIT	2

@interface GameState : NSObject
{
	CFTimeInterval _timeElapsed, _nextStateTime;
	GameState *_nextState, *_lastState;
	BOOL _waitingOnSignal;
	NSData *_dataBin;
	int _closeDataBin;
}

@property(readwrite) CFTimeInterval timeElapsed;
@property(readwrite, retain) NSData *dataBin;
@property(readwrite, assign) int closeDataBin;

+ (GameState *) getCurrentState;
+ (void)  handleEvent: (GameState *) next;

- (void) changeTo: (GameState *) next at: (CFTimeInterval) time;
- (void) changeTo: (GameState *) next after: (float) time;
- (void) whenSignaledChangeTo: (GameState *) next;
- (void) signal;

- (GameState *) timer: (CFTimeInterval) dTime;
- (GameState *) startTouch:(NSSet *)touches withEvent:(UIEvent *)event;
- (GameState *) drag: (NSSet *)touches withEvent:(UIEvent *)event;
- (GameState *) endTouch:(NSSet *)touches withEvent:(UIEvent *)event;
- (GameState *) handleData: (NSData *) data;
- (GameState *) endData: (BOOL) playerQuit;
- (GameState *) accelerometer:(float *)acceleration;

@end

@interface GameState(SubclassOverloads)
- (void) enter;
- (void) leave;
- (void) leaving;
- (GameState *) doStartTouch:(NSSet *)touches withEvent:(UIEvent *)event;
- (GameState *) doDrag: (NSSet *)touches withEvent:(UIEvent *)event;
- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event;
- (GameState *) doTimer: (CFTimeInterval) dTime;
- (GameState *) doData:(NSData *) data;
- (GameState *) doEndData:(BOOL) playerQuit;
- (GameState *) doAccelerometer:(float *)acceleration;
@end

@interface GameState(PongVadersSpecific)
- (void) cleanupLabel: (CCLabelTTF *) label;
- (int) getPowerup;
- (int) getPowerupChance;
@end