//
//  CPTDawdle.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invader.h"
#import "GameSettings.h"

#define DAWDLE_NUM_FRAMES 16
#define DAWDLE_MAX_HEALTH 50

@interface CPTDawdle : Invader {
	CCAnimation *_dawdle;
	ccTime _animTime;
	int _lastFrame;
	BOOL _upsidedown;
	BOOL _shaking;
	ccTime _shakeTime, _explosionTime;
}

@end
