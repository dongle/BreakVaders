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
//#import "GLES-Render.h"
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
#import "VictoryScreen.h"
#import "GameStates.h"
#import "SettingsManager.h"
#import "NamedParticleSystem.h"
#import "ShakeDispatcher.h"
#import "GameSettings.h"
//#import "Crittercism.h"
#import "StoreObserver.h"

// OpenFeint stuff
#import "CCOFDelegate.h"
#import "OpenFeint.h"
#import "CCOFAchievementDelegate.h"

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
@interface PongVader : CCLayer <ShakeEventListenerProtocol, StoreResponder> {

	GLESDebugDraw *m_debugDraw;
	
	// Box2D stuff
	b2World *world;
	b2Body *groundBody;
	
	// hold these fixtures to determine when ball has escaped
	b2Fixture *bottomFixture;
	b2Fixture *topFixture;
	b2Fixture *leftFixture;
	b2Fixture *rightFixture;
	
	// player stuff
	Paddle *paddle1;
	Paddle *paddle2;

	// graphics 
	
	CCSpriteSheet *sheet;
	
	Planet *planet[2];
	StarField *starfield;
	
	CCSprite *effectring;
	CCAnimation *effectringanim;
	
	// tracking game entities
	NSMutableArray *fleets, *balls, *powerups, *activeParticles;
	NSMutableDictionary *inactiveInvaders, *inactiveParticles;
	
	// interactive
	ContactListener *_contactListener;
	NSMutableArray *touchedSprites;
	
	// player stuff
	Player *player[2];
	
	// state info

	BOOL bulletTime, innerBulletRadius;
	BOOL soloInvader;
	BOOL bossTime;
	BOOL OFstarted;
	BOOL gameBeat;
	
	float bulletTimeDistance;
	
	SettingsManager *settings;
	NSMutableDictionary *appPList;
	
	CCOFDelegate *ofDelegate;
	CCOFAchievementDelegate *myAchievementDelegate;
	
	// Difficulty constraints
	float numBalls, minSpeed, maxSpeed;
	
	// tracking achievement stuff
	BOOL gotFireball;
	
	NSString *track1;
	NSString *track2;
	NSString *track3;
	NSString *track4;
	
	NSString *smallFont;
	NSString *mediumFont;
	NSString *largeFont;
	
	CDSoundSource *fuzz;
	
	// tracking request dialogs (one per session)
	BOOL sentRequest;
	
	UIViewController *mainViewController;
	
	ccTime physDt;
	
	b2Vec2 oldImpulse;
	CGFloat baseAccel[3];
	BOOL accelNormalized;
}

@property (readonly) b2World *world;
@property (readwrite, assign) b2Vec2 oldImpulse;
@property (readonly) NSMutableArray *fleets;
@property (readonly) NSMutableArray *powerups;
@property (readonly) CCSpriteSheet *sheet;
@property (readonly) StarField *starfield;
@property (readonly) BOOL bulletTime, innerBulletRadius;
@property (readwrite, assign) NSMutableArray *balls;
@property (readwrite, assign) BOOL bossTime, OFstarted, gotFireball, frozen;
@property (readonly) SettingsManager *settings;
@property (readonly) Player **player;
@property (readonly) Planet **planet;
@property (readonly) Paddle *paddle1, *paddle2;
@property (readwrite, assign) float numBalls, minSpeed, maxSpeed, bulletTimeDistance;
@property (readwrite, assign) BOOL gameBeat;
@property (readonly) NSString *track1, *track2, *track3, *track4, *smallFont, *mediumFont, *largeFont;
@property (readwrite, assign) BOOL sentRequest, accelNormalized;
@property(nonatomic, retain) UIViewController *mainViewController;

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

- (void) initOpenFeint;
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
