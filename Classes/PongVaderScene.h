//
//  PongVaderScene.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright Koduco Games 2010. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "SpriteBody.h"
#import "Ball.h"
#import "Rock.h"
#import "Fleet.h"
#import "Paddle.h"
#import "Planet.h"
#import "StarField.h"
#import "TouchedSprite.h"
#import "ContactListener.h"
#import "AABBQueryCallback.h"
#import <stdlib.h>
#import "SimpleAudioEngine.h"
#import "GameStates.h"
#import "SettingsManager.h"
#import "NamedParticleSystem.h"
#import "GameSettings.h"

// invader types
#import "Invader.h"
#import "ENSPrance.h"
#import "LTWaddle.h"
#import "CDRBobble.h"
#import "StationaryInvader.h"
#import "DynamicInvader.h"
#import "ShieldInvader.h"

#import "Powerup.h"

#define MAX_FLEETS 5

#define PV_NUM_LEVELS 25

// PongVader Layer
@interface PongVader : CCLayer {
	
	// Box2D stuff
	b2World *_world;
	b2Body *_groundBody;
	
	// hold these fixtures to determine when ball has escaped
	b2Fixture *_bottomFixture;
	b2Fixture *_topFixture;
	b2Fixture *_leftFixture;
	b2Fixture *_rightFixture;
	
	// player stuff
	Paddle *_paddle1;
	Paddle *_paddle2;

	// graphics 
	
	CCSpriteBatchNode *_sheet;
	
	Planet *_planet[2];
	StarField *_starfield;
	
	CCSprite *_effectring;
	CCAnimation *_effectringanim;
	
	// tracking game entities
	NSMutableArray *_fleets, *_balls, *_powerups, *_activeParticles;
	NSMutableDictionary *_inactiveInvaders, *_inactiveParticles;
	
	// interactive
	ContactListener *_contactListener;
	NSMutableArray *_touchedSprites;
	
	// player stuff
	Player *_player[2];
	
	// state info

	BOOL _bulletTime, _innerBulletRadius;
	BOOL _soloInvader;
	BOOL _bossTime;
	BOOL _OFstarted;
	BOOL _gameBeat;
	
	float _bulletTimeDistance;
	
	SettingsManager *_settings;
	NSMutableDictionary *_appPList;
	
	// Difficulty constraints
	float _numBalls, _minSpeed, _maxSpeed;
	
	// tracking achievement stuff
	BOOL gotFireball;
	
	NSString *_track1;
	NSString *_track2;
	NSString *_track3;
	NSString *_track4;
	
    NSString *_fontName;
	CGFloat  _smallFont;
	CGFloat  _mediumFont;
	CGFloat  _largeFont;
	
	CDSoundSource *_fuzz;
	
	// tracking request dialogs (one per session)
	BOOL _sentRequest;
	
	UIViewController *_mainViewController;
	
	ccTime _physDt;
	
	b2Vec2 _oldImpulse;
	CGFloat _baseAccel[3];
	BOOL _accelNormalized;
    BOOL _isFourInch;
}

@property (readonly) b2World *world;
@property (readwrite, assign) b2Vec2 oldImpulse;
@property (readonly) NSMutableArray *fleets;
@property (readonly) NSMutableArray *powerups;
@property (readonly) CCSpriteBatchNode *sheet;
@property (readonly) StarField *starfield;
@property (readonly) BOOL bulletTime, innerBulletRadius;
@property (readwrite, assign) NSMutableArray *balls;
@property (readwrite, assign) BOOL bossTime, OFstarted, gotFireball, frozen;
@property (readonly) SettingsManager *settings;
@property (readonly) Player __weak **player;
@property (readonly) Planet __weak **planet;
@property (readonly) Paddle *paddle1, *paddle2;
@property (readwrite, assign) float numBalls, minSpeed, maxSpeed, bulletTimeDistance;
@property (readwrite, assign) BOOL gameBeat;
@property (readonly) NSString *track1, *track2, *track3, *track4, *fontName;
@property (readonly) CGFloat smallFont, mediumFont, largeFont;
@property (readwrite, assign) BOOL sentRequest, accelNormalized;
@property(nonatomic, retain) UIViewController *mainViewController;
@property (nonatomic, assign) BOOL isFourInch;

// returns a Scene that contains the PongVader as the only child
+(id) scene;
+(PongVader *) getInstance;

- (void) writeToPersist;

- (void) showPaddles: (BOOL) isVisible;
- (void) addFleet: (Fleet *) fleet;
- (SpriteBody *) addSpriteBody: (Class) spriteBodyClass atPos: (CGPoint) p withForce: (CGPoint) f;
- (void) destroyInvader: (SpriteBody<Shooter> *) invader inGame: (BOOL) ingame;
- (void) clearScene; // removes all invaders and balls
- (void) resetScene; // resets planets
- (BOOL) isGameLost;
- (BOOL) isGameWon;

// handle universal scene interactions (paddle motion, physics, invader deaths)
- (void) doTick: (ccTime) dt;
- (void) doTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) doTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) doTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) clearTouches;

+ (float) spriteDistance: (SpriteBody *) sprite1 sprite2: (SpriteBody *) sprite2;

- (void) doExplosionAt:(CGPoint)p fromDyn:(DynamicInvader *)inv;

- (void) setDifficulty: (int) level;

- (float) randBallMagnitude;

//- (void) initOpenFeint;
- (void) updateOFScores;

// these should probably not be called directly, use clearScene / resetScene
- (void) clearBalls;
- (void) clearPowerups;
- (void) destroyPowerups;
- (void) clearInvaders;

- (void) setBackgroundVolume: (float) volume;

- (Ball *) closestBallTo: (CGPoint) pos maxDist: (float)maxDist;

- (void) terminating;

- (void) addParticleAt: (CGPoint) pos particleType: (int) ptype;
@end
