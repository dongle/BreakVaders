//
//  SNEye.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 1/21/11.
//  Copyright 2011 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invader.h"
#import "GameSettings.h"
#import "cocos2d.h"
#import "Ball.h"

#define EYE_NUM_FRAMES 5
#define EYE_MAX_HEALTH 5
#define NUMSHOTS 20
#define EYE_FREEZETIME 1.5

#define EYE_BUFFERX_PHN 50
#define EYE_BUFFERX_PAD 100

#define EYE_BUFFERY_PHN 128
#define EYE_BUFFERY_PAD 256

@interface SNEye : Invader {
	CCAnimation *_eyeOpen, *_eyeClose, *_deadEye;
	ccTime _animTime;
	int _lastFrame;
	BOOL _shaking, _frozen, _preShoot;
	ccTime _shakeTime, _explosionTime, _frozenTime;
	CCSprite *_fragment1, *_fragment2, *_fragment3, *_fragment4;
	CCLayerColor *_flash;
}

@property (readwrite, assign) BOOL frozen, shaking, preShoot;
@property (readwrite, assign) ccTime frozenTime;
@property (nonatomic, retain) CCAnimation *eyeOpen, *eyeClose, *deadEye;
@property (nonatomic, retain) CCSprite *fragment1, *fragment2, *fragment3, *fragment4;
@property (nonatomic, retain) CCLayerColor *flash;

@end
