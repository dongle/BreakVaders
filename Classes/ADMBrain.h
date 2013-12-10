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
	BOOL _upsidedown;
	BOOL _shaking;
	BOOL _paused;
	ccTime _shakeTime;
	Invader *_tail;
	Invader *_segs[BRAIN_MAX_SEGS];
	CGPoint _prevs[BRAIN_MAX_SEGS+1];
	int _segcount;
	float _xmax, _xmin, _ymax, _ymin;
	float _bspeed; // brain speed
	CGPoint _bdir; // brain direction
	Fleet *_fleet;
	
	float _scaleFactor;
}

@property (nonatomic, retain) Invader *tail;
@property (nonatomic, readonly) Fleet *fleet;
@property (readwrite, assign) BOOL paused;
@property (readwrite, assign) BOOL upsidedown;

- (void) doRotate;

@end
