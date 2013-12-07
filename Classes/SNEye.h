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
	CCAnimation *eyeOpen, *eyeClose, *deadEye;
	ccTime animTime;
	int lastFrame;
	BOOL shaking, frozen, preShoot;
	ccTime shakeTime, explosionTime, frozenTime;
	CCSprite *fragment1, *fragment2, *fragment3, *fragment4;
	CCColorLayer *flash;
}

@property (readwrite, assign) BOOL frozen, shaking, preShoot;
@property (readwrite, assign) ccTime frozenTime;
@property (nonatomic, retain) CCAnimation *eyeOpen, *eyeClose, *deadEye;
@property (nonatomic, retain) CCSprite *fragment1, *fragment2, *fragment3, *fragment4;
@property (nonatomic, retain) CCColorLayer *flash;

@end
