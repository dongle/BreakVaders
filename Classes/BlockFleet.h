//
//  BlockFleet.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Fleet.h"
#import "GameSettings.h"

#define BLOCKFLEET_ANIM_TIME 0.1
#define BLOCKFLEET_START_SIZE 5
#define BLOCKFLEET_CELLSIZE 35

// invader defs naming convention
// INV_<R|P><EN|LT|CD><U|D>
// <R|P> regular or promoted
// <EN|LT|CD|ST|SH|DY> ensign, liutenant, commander, stationary, shield, dynamic
// <U|D> oriented up or down

#define INV_RENU 'a' // ENSPrance
#define INV_PENU 'A' 
#define INV_REND 'q' 
#define INV_PEND 'Q' 
#define INV_RLTU 's' // LTWaddle
#define INV_PLTU 'S'
#define INV_RLTD 'w'
#define INV_PLTD 'W'
#define INV_RCDU 'd' // CDRBobble
#define INV_PCDU 'D'
#define INV_RCDD 'e'
#define INV_PCDD 'E'
#define INV_RSTU 'f' // StationaryInvader
#define INV_RSTD 'r'
#define INV_RSHU 't' // ShieldInvader
#define INV_RSHD 'T'
#define INV_RDYU 'y' // DynamicInvader
#define INV_RDYD 'Y'

#define INV_RASU 'z' // Rock (asteroid)
#define INV_RASD 'Z'
#define INV_RB1U '1' // Boss 1 (CPTDawdle)
#define INV_RB1D '!'
#define INV_RB2U '2' // Boss 2 (ADMBrain)
#define INV_RB2D '@'
#define INV_RB0U '0' // Boss 0 (SNEye)

Class char2class(char invType);
BOOL isInvUpsideDown(char invType);
BOOL isInvPromoted(char invType);
BOOL shouldAnimateReveal(char invType);

@interface BlockFleet : Fleet {
	CGPoint _origin;
	CGPoint _dimensions;
	CGFloat _spacing;
	NSString *_score;
	//bool lastShotUp;
}

- (id) initWithConfig: (char *) config
			  andDims: (CGPoint) dims 
		  withSpacing: (float) space
			 atOrigin: (CGPoint) atorigin 
			fromRight: (BOOL) fromright
			  playing: (NSString *) scoretoplay
		   difficulty: (int) level;
- (void) moveFleet;

@end
