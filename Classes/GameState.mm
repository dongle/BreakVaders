//
//  GameState.m
//  Toe2Toe
//
//  Created by Cole Krumbholz on 10/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "GameState.h"
#import "PongVaderScene.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

static GameState * _curState;

@implementation GameState

@synthesize timeElapsed = _timeElapsed;
@synthesize dataBin = _dataBin;
@synthesize closeDataBin = _closeDataBin;

#pragma mark Class methods

+ (void) initialize { 
	static BOOL initialized = NO; 
	if (!initialized) { 
		_curState = nil;
		initialized = YES;
	} 
} 

+ (GameState *) getCurrentState {
	return _curState;
}

+ (void) handleEvent: (GameState *) next {
	if (next != _curState) 
	{
		GameState *oldState = _curState;

		if (oldState) {
			[oldState->_nextState autorelease];
			oldState->_nextState = next;
			oldState->_nextStateTime = 0;
			oldState->_waitingOnSignal = NO;
		}
		
		if ((_curState = [next retain]))
			_curState->_lastState = oldState;
		
		[oldState leave];
		if (_curState) _curState.timeElapsed = 0;
		[_curState enter];

		if ( oldState)  oldState->_nextState = nil;
		if (_curState) _curState->_lastState = nil;
		
		// we are now in a new state, pass any stored data
		
		if (oldState.closeDataBin == kSTATE_CLOSE_DATA) {
			[_curState changeTo: [_curState endData:NO] at: 0.2];
		} else if (oldState.closeDataBin == kSTATE_CLOSE_DATA_QUIT) {
			[_curState changeTo: [_curState endData:YES] at: 0.2];
		} else if (oldState.dataBin) {
			[_curState changeTo: [_curState handleData:oldState.dataBin] at: 0.2];
		}
		
		// cleanup
		
		[oldState autorelease];
	}
}

#pragma mark Constructors / Destructors

- (id) init{
	if ((self = [super init])) 
	{
		_lastState = nil;
		_nextState = nil;
		_nextStateTime = 0;
		_timeElapsed = 0;
		_waitingOnSignal = NO;
		_dataBin = nil;
		_closeDataBin = kSTATE_NO_CLOSE_DATA;
        
        // This screen name value will remain set on the tracker and sent with
        // hits until it is set to a new value or to nil.
        [[GAI sharedInstance].defaultTracker set:kGAIScreenName
                                           value:NSStringFromClass([self class])];
        
        // Send the screen view.
        [[GAI sharedInstance].defaultTracker
         send:[[GAIDictionaryBuilder createAppView] build]];
	}
	return self;
}

- (void) dealloc {
	[_dataBin release];
	[_nextState release];
	[super dealloc];
}

#pragma mark Default do... methods

//
// Default do... methods. 
// Should be overloaded to create functionality for the sub-state
//

- (void) enter {}
- (void) leave {}
- (void) leaving {}

- (GameState *) doStartTouch:(NSSet *)touches withEvent:(UIEvent *)event { return self; }
- (GameState *) doDrag: (NSSet *)touches withEvent:(UIEvent *)event { return self; }
- (GameState *) doEndTouch:(NSSet *)touches withEvent:(UIEvent *)event { return self; }
- (GameState *) doTimer: (CFTimeInterval) dTime { return self; }

- (GameState *) doData:(NSData *) data {
	// default behavior is just to store the data
	[self setDataBin: data];
	return self; 
}

- (GameState *) doEndData:(BOOL) playerQuit { 
	// default behavior is just to store the closeData
	_closeDataBin = playerQuit ? kSTATE_CLOSE_DATA_QUIT
							  : kSTATE_CLOSE_DATA;
	return self; 
}

- (GameState *) doAccelerometer:(float *)acceleration
{ return self; }

#pragma mark Public methods

//
// Public methods.
// Called by clients of the class to invoke state-specific behavior
//

- (void) changeTo: (GameState *) next after: (float) time {
	[self changeTo: next at: _timeElapsed + time];
}


- (void) changeTo: (GameState *) next at: (CFTimeInterval) time {
	if (next == self) return;
	
	[_nextState autorelease];
	_nextState = [next retain];
	_nextStateTime = time;
	[self leaving];
}

- (void) whenSignaledChangeTo: (GameState *) next {
	if (next == self) return;
	
	[_nextState autorelease];
	_nextState = [next retain];
	_waitingOnSignal = YES;
	[self leaving];
}

- (void) signal {
	_waitingOnSignal = NO;
}

- (GameState *) timer: (CFTimeInterval) dTime {
	_timeElapsed += dTime;
	if (!_nextState) {
		return [self doTimer:dTime];
	} else if (!_waitingOnSignal && (_timeElapsed > _nextStateTime)) {
		return _nextState;
	} else return self;
}

- (GameState *) startTouch:(NSSet *)touches withEvent:(UIEvent *)event { 
	if (!_nextState) return [self doStartTouch:touches withEvent:event];
	else return self;
}

- (GameState *) drag: (NSSet *)touches withEvent:(UIEvent *)event { 
	if (!_nextState) return [self doDrag:touches withEvent:event];
	else return self;
}

- (GameState *) endTouch:(NSSet *)touches withEvent:(UIEvent *)event { 
	if (!_nextState) return [self doEndTouch:touches withEvent:event];
	else return self;
}

- (GameState *) handleData: (NSData *) data { 
	if (_nextState) {
		[self setDataBin: data];
		return self;
	} else 
		return [self doData:data]; 
}

- (GameState *) endData: (BOOL) playerQuit { 
	if (_nextState) {
		_closeDataBin = playerQuit ? kSTATE_CLOSE_DATA_QUIT
								  : kSTATE_CLOSE_DATA;
		return self;
	} else
		return [self doEndData: playerQuit]; 
}

- (GameState *) accelerometer:(float *)acceleration {
	if (!_nextState) return [self doAccelerometer: acceleration];
	else return self;	
}

#pragma mark PongVaders Specific

- (void) cleanupLabel: (CCLabelTTF *) label {
	PongVader *pv = [PongVader getInstance];
	
	[pv removeChild:label cleanup:YES];
	[label release];
}

- (int) getPowerup {
	int effect = 0;
	// spawn powerups of random type
	int powerupType = arc4random() % 4;
	switch (powerupType) {
		case 0:
			effect = POW_ENSPRANCE;
			break;
		case 1:
			effect = POW_LTWADDLE;
			break;
		case 2:
			effect = POW_CDRBOBBLE;
			break;
		case 3:
			effect = POW_STAT;
		default:
			break;
	}
	return effect;
}

- (int) getPowerupChance {
	return POWERUP_PERCENT;
}

@end

