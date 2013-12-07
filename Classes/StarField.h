//
//  StarField.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BeatNode.h"
#import "GameSettings.h"

#define NUM_STARS 256
#define STAR_MIN_SIZE 1.0
#define STAR_MAX_SIZE 2
#define STAR_BASE_R 0
#define STAR_BASE_G 0
#define STAR_BASE_B 255
#define NUM_STAR_TYPES 3
#define STARFIELD_SIZE 1452.0
#define STARFIELD_DIVS 16

@interface StarField : BeatNode {
	CCSprite *star[NUM_STARS];
	ccTime curTime, driftTime;
}
+(StarField *) starField;
-(void) doDrift;
-(void) reset;
-(void) tick: (ccTime) dt;
@end
