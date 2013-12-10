//
//  GameSettings.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/9/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif

// DEBUG
#define DEBUG_SKIPLEVEL NO
#define BOUGHT_FULLGAME NO
#define UPGRADE_BUTTON NO
#define ALL_LEVELS_AVAIL NO
#define RESTART_LEVEL 0

// Ports/versions
// IPAD / IPHONE CUSTOMIZATION
#define _IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

// PLANET STUFF
#define PLANET_MOTION_FACTOR 10.0
#define PLANET_PARALAX_RATIO 0.3
#define PLANET_SHAKE_DURATION 2.0
#define PLANET_REGEN_TIME 4.0  // seconds per point of health
#define PLANET_MAX_HEALTH 7.0f // this must be a float 

#define COSMIC_DRIFT 25.0
#define COSMIC_ROT_FACTOR 5.0

// PADDLE STUFF
#define PADDLE_DEFAULT_WIDTH 192
#define PADDLE_DEFAULT_WIDTH_IPHONE 75 // 75
#define PADDLE_SCALE 2
#define PADDLE_SCALE_IPHONE 2
#define USE_DYNAMIC_PADDLES NO
#define AUTOPLAY NO
#define FULLAUTO NO

// BALL STUFF
#define MAX_BOUNCES 100
#define RIBBON_FADE_TIME 1.0 
#define RIBBON_TO_CUR_POS NO
#define RIBBON_TAPER NO

// INVADER  & SHOOTING STUFF (some deprecated)
#define TIMETOSHOOT 8
#define TIMETOMOVE 2
#define MOVEDISTANCE 50

#define MAXBALLSPEED 15.0
#define MINBALLSPEED 1.0
#define IMPOSSIBLEBALLSPEED 20.0
#define LEVELSTOMAX 15
#define BALLHITS 1

// GAME PROPERTIES
#define BULLETTIME .1

#define GAME_BPM 100
#define GAME_SPB (1/(GAME_BPM/60.0f))

#define EFFECT_ACTION 0x0010

// collision categories
#define COL_CAT_BALL 0x0001
#define COL_CAT_WALL 0x0002 
#define COL_CAT_PADDLE 0x0004
#define COL_CAT_INVADER 0x0008
#define COL_CAT_DYNVADER 0x0010
#define COL_CAT_ROCK 0x0020

// powerup / status definitions
#define POW_ENSPRANCE 1
#define SHRINK 2
#define EXTEND 1
#define POW_LTWADDLE 3
#define POW_CDRBOBBLE 4
#define POW_STAT 5
#define POW_SHLD 6

#define POWERUP_PERCENT 10

#define POWERUP_LENGTH 10

// scoring
#define SCORE_GETPOWERUP 500
#define SCORE_PLANETHIT -200
#define SCORE_REBOUNDBALL 10
#define SCORE_HITINVADER 50
#define SCORE_DESTROYENS 100
#define SCORE_DESTROYLT 200
#define SCORE_DESTROYCDR 500
#define SCORE_DESTROYSHLD 300

#define SCORE_CHAINMULT 10

// particles
#define PART_DYN 1
#define PART_BALL 2
#define PART_POW 3

// HURF

// action tags
#define ACTION_TAG_FLASHING 101

// ACHIEVEMENTS
#pragma once 

#define HOT_BALLS @"516324" 
#define BALL_MASTER @"516824" 
#define HIGH_AS_BALLS @"516834" 
#define BALL_BOUNCER @"516844" 
#define BALL_JUGGLER_10 @"516854" 
#define BALL_JUGGLER_20 @"516864" 
#define BALL_JUGGLER_50 @"516874" 
#define BALL_JUGGLER_100 @"516884" 
#define BIG_BALLER @"516894" 

// MUSIC

#define MUSIC_FADE_TIME .5
#define MUSIC_FADE_TIME_BULLET 1
#define TRANSITION_PAUSE 1.25
#define MENU_TRANSITION_PAUSE .5
#define POST_GAME_PAUSE 3.0

// UI STUFF

#define LABEL_PADDING 20
#define LABEL_FONT @"pvaders.fnt"
#define SKIP_RECT CGRectMake(650, 0, 100, 75)
#define SKIP_POS (_IPAD?ccp(600, 25):ccp(250, 12))
#define SKIP_POS_TOP (_IPAD?ccp(600, 960):ccp(250, 440))
#define TUTLABEL_POS (_IPAD?ccp(200, 960):ccp(100, 440))
#define INTRO_YSHIFT (_IPAD?112:50)

#define PROLOGUE_LEVEL 0
#define EPISODE_ONE_LEVEL 11
#define EPISODE_TWO_LEVEL 22

// MOVIES

#define MAX_MOVIE_ACTIONS 64
#define CREDITS_LENGTH 25
#define PICTURE_TRANSITION .5
#define PICTURE_LENGTH 5

// ADM BRAIN

#define BRAIN_INIT_SPD 200
#define BRAIN_INIT_SPD_IPHONE 100
#define BRAIN_SPD_INC 40
#define BRAIN_MAX_SEGS 10
#define BRAIN_MAX_SEGS_IPHONE 8
#define BRAIN_SEG_DIST 40
#define BRAIN_MAX_HEALTH (BRAIN_MAX_SEGS-2)
#define BRAIN_MAX_HEALTH_IPHONE (BRAIN_MAX_SEGS_IPHONE-2)
#define BRAIN_SMOOTH_FAC 0.8 // smoothing factor for tail
#define BRAIN_SEEK_FAC 1.0	// how much does the tail seek nearest ball
#define BRAIN_WHIP_FAC 0.1 // how much does the tail whip around

