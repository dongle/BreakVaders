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
	CCAnimation *dawdle;
	ccTime animTime;
	int lastFrame;
	BOOL upsidedown;
	BOOL shaking;
	ccTime shakeTime, explosionTime;
}

@end
