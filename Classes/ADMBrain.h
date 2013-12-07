//
//  ADMBrain.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 8/9/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invader.h"
#import "Fleet.h"

#define BRAIN_NUM_FRAMES 4

@interface ADMBrain : Invader {
	//CCAnimation *fly;
@public
	BOOL upsidedown;
	BOOL shaking;
	BOOL paused;
	ccTime shakeTime;
	Invader *tail;
	Invader *segs[BRAIN_MAX_SEGS];
	CGPoint prevs[BRAIN_MAX_SEGS+1];
	int segcount;
	float xmax, xmin, ymax, ymin;
	float bspeed; // brain speed 
	CGPoint bdir; // brain direction
	Fleet *fleet;
	
	float scaleFactor;
}

@property (nonatomic, retain) SpriteBody *tail;
@property (nonatomic, readonly) Fleet *fleet;
@property (readwrite, assign) BOOL paused;
@property (readwrite, assign) BOOL upsidedown;

- (void) doRotate;

@end
