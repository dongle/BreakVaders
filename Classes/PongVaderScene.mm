//
//  PongVaderScene.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright Koduco Games 2010. All rights reserved.
//


// Import the interfaces
#import "PongVaderScene.h"
#import "GameStates.h"
#import <vector>
#import "Utils.h"
//#import "TapZillaCoupon.h"
#import "OpenFeint.h"
#import "OFAchievement.h"
#import "OFHighScoreService.h"
#import "OFAchievementService.h"
#import "ADMBrainSeg.h"
#import "ADMBrainTail.h"
#import "UFO.h"
#import "AdLoader.h"
#import "Reachable.h"

#define RADIANS( degrees ) ( degrees * M_PI / 180 )

using namespace std;

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagSpriteSheet = 1,
	kTagAnimation1 = 1,
};

@interface PongVader (Private)
- (void) retireParticles;
- (void) paddleContact: (Paddle*) p withBall: (Ball*) b;
- (void) paddleContact: (Paddle*) p withDyn: (DynamicInvader*) b;
- (void) destroyBalls;
- (void) cleanupInvader: (SpriteBody<Shooter> *) deadInvader;
- (void) destroyInvaders;
- (void) cacheSomeSpriteBodies: (Class) spriteBodyClass number: (int) num;
- (void) doExplosionAt:(CGPoint)p fromDyn:(DynamicInvader *)inv;
@end

@interface CCRepeatForever (Access)
- (CCAction *) getOther;
@end

@implementation CCRepeatForever (Access)
- (CCAction *) getOther {
	return other;
}
@end


// PongVader implementation
@implementation PongVader

#pragma mark initialization routines ----------------------------------------

@synthesize world, fleets, starfield, balls, bossTime, frozen, OFstarted, bulletTime, innerBulletRadius, bulletTimeDistance, sheet, settings, 
	numBalls, minSpeed, maxSpeed, gotFireball, gameBeat, track1, track2, track3, track4, smallFont, mediumFont, largeFont,
	paddle1, paddle2, powerups, sentRequest, mainViewController, oldImpulse, accelNormalized;

- (Player **) player {
	return player;
}

- (Planet **) planet {
	return planet;
}

+(id) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PongVader *layer = [PongVader getInstance];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

static PongVader *_globalSceneInst = nil;

+(PongVader *) getInstance {
	if (_globalSceneInst == nil) 
		_globalSceneInst = [PongVader node];
	return _globalSceneInst;
}

// initialize your instance here
-(id) init {
	if( (self=[super init])) {
		
		// allocate variables
		
		activeParticles = [[NSMutableArray array] retain];
		inactiveParticles = [[NSMutableDictionary dictionary] retain];
		inactiveInvaders = [[NSMutableDictionary dictionary] retain];
		
		fleets = [[NSMutableArray array] retain];
		_contactListener = new ContactListener();
		touchedSprites = [[NSMutableArray alloc] initWithCapacity:11];
		balls = [[NSMutableArray array] retain];
		powerups = [[NSMutableArray array] retain];
		_globalSceneInst = self;

		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		self.accelNormalized = NO;		
		
		// background stuff
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		starfield = [StarField starField];
		[self addChild:starfield];
		
		planet[0] = [[Planet alloc] initAt:ccp(screenSize.width/2.0, 0) upsideDown:NO];
		planet[1] = [[Planet alloc] initAt:ccp(screenSize.width/2.0, screenSize.height) upsideDown:YES];
		//planet[1].rotation = 180;
		[self addChild:planet[0]];
		[self addChild:planet[1]];
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContactListener(_contactListener);
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
		//		flags += b2DebugDraw::e_jointBit;
		//		flags += b2DebugDraw::e_aabbBit;
		//		flags += b2DebugDraw::e_pairBit;
		//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		groundBody = world->CreateBody(&groundBodyDef);
		
		// Define the ground box shape.
		b2PolygonShape groundBox;
		b2FixtureDef groundShapeDef;
		groundShapeDef.shape = &groundBox;
		groundShapeDef.density = 0.0f;
		groundShapeDef.filter.categoryBits = COL_CAT_WALL;
		groundShapeDef.filter.maskBits = COL_CAT_BALL | COL_CAT_DYNVADER;
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		bottomFixture = groundBody->CreateFixture(&groundShapeDef);
		
		// top
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
		topFixture = groundBody->CreateFixture(&groundShapeDef);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
		leftFixture = groundBody->CreateFixture(&groundShapeDef);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		rightFixture = groundBody->CreateFixture(&groundShapeDef);
		
		// init players
		// TODO: change this static player initialization to prompt for player names
		
		player[0] = [[Player alloc] initWithName: @"player1"];
		player[1] = [[Player alloc] initWithName: @"player2"];
		
		// make paddles
		if (_IPAD) {
			paddle1 = (Paddle *) [Paddle spriteBodyAt:ccp(screenSize.width/2, 132) withForce: ccp(0,0) inWorld: world];
			paddle2 = (Paddle *) [Paddle spriteBodyAt:ccp(screenSize.width/2, 892) withForce: ccp(0,0) inWorld: world];
		}
		else {
			paddle1 = (Paddle *) [Paddle spriteBodyAt:ccp(screenSize.width/2, 66) withForce: ccp(0,0) inWorld: world];
			paddle2 = (Paddle *) [Paddle spriteBodyAt:ccp(screenSize.width/2, 414) withForce: ccp(0,0) inWorld: world];
		}
		
		paddle1.player = player[0];
		paddle2.player = player[1];
		
		[self addChild:paddle1];
		[self addChild:paddle2];
		
		[self showPaddles:NO];

		// add effect ring
		
		effectring = [[CCSprite spriteWithFile:@"effectring0.png"] retain];
		effectring.scale = _IPAD?2.0:1.0;
		[effectring.texture setAliasTexParameters];
		effectring.visible = NO;
		//effectring.position = ccp(screenSize.width/2, screenSize.height/2);

		[self addChild:effectring];
		
		effectringanim = [[CCAnimation animationWithName:@"anim" delay:0.2] retain];
		for (int i=0; i<8; i++) {
			CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"effectring%d.png", i]];
			CGRect rect = CGRectZero;
			rect.size = texture.contentSize;
			CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect offset:CGPointZero];
			[frame.texture setAliasTexParameters];
			[effectringanim addFrame:frame];
		}
		
		/*
		NSMutableArray *animFrames = [NSMutableArray array];
		for (int i=0; i<4; i++) {
			CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"effectring%d.png", i]];
			[frame.texture setAliasTexParameters];
			[animFrames addObject:frame];
		}
		effectringanim = [CCAnimation animationWithName:@"anim" delay:GAME_SPB/3.0f frames:animFrames];
		*/

		CCAnimate *animate = [CCAnimate actionWithAnimation:effectringanim restoreOriginalFrame:NO];
		CCAction *action = [effectring runAction:[CCRepeatForever actionWithAction: animate]];
		action.tag = EFFECT_ACTION;
		
		// starting last acceleration

		baseAccel[0] = 0.0;
		baseAccel[1] = 0.0;
		baseAccel[2] = -1.0;
		
		
		// create global sprite sheet
//		if (_IPAD) {
//			sheet = [CCSpriteSheet spriteSheetWithFile:@"pongvaders.png"];
//			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pongvaders.plist"];
//		}
//		else {
//			sheet = [CCSpriteSheet spriteSheetWithFile:@"pongvaders-low.png"];
//			[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pongvaders-low.plist"];
//		}
		
		sheet = [CCSpriteSheet spriteSheetWithFile:@"pongvaders-low.png"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pongvaders-low.plist"];
		
		[self addChild:sheet];	
		
		[[sheet texture] setAliasTexParameters];
		
		// preload stuff for cocosdenshion sound
		
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"boom.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"shoot.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"powerup.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"boink.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"warp.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"planet.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"redpaddle.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"greenshot.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"mine.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"expand.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"lose.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"slice.wav"];
		//[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"fuzz.wav"];
		fuzz = [[[SimpleAudioEngine sharedEngine] soundSourceForFile:@"homing.wav"] retain];
		fuzz.looping = YES;
		
		// [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.2;
		//[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"draftloop-01.mp3"];
//		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"draftloop-01.mp3"];
//		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		
		track1 = @"draftloop-01.mp3";
		track2 = @"draftloop-02.mp3";
		track3 = @"draftloop-03.mp3";
		track4 = @"draftloop-04.mp3";
		NSLog(@"loading hifi music \n");
		
		if (_IPAD) {			
			smallFont = @"pvaders16.fnt";
			mediumFont = @"pvaders24.fnt";
			largeFont = @"pvaders32.fnt";
		}
		
		else {
			/*
			track1 = @"draftloop01-low.mp3";
			track2 = @"draftloop02-low.mp3";
			track3 = @"draftloop03-low.mp3";
			track4 = @"draftloop04-low.mp3";
			NSLog(@"loading lowfi music \n");
			*/
			
			smallFont = @"pvaders12.fnt";
			mediumFont = @"pvaders16.fnt";
			largeFont = @"pvaders24.fnt";
		}
		
		// preload fonts and set alias tex params
		
		CCBitmapFontAtlas * smAtlas = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"tmp" fntFile:smallFont];
		CCBitmapFontAtlas * mdAtlas = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"tmp" fntFile:mediumFont];
		CCBitmapFontAtlas * lgAtlas = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"tmp" fntFile:largeFont];
		[smAtlas.texture setAliasTexParameters];
		[mdAtlas.texture setAliasTexParameters];
		[lgAtlas.texture setAliasTexParameters];
		
		// cache sprite bodies
		[self cacheSomeSpriteBodies:[Invader class] number:10];
		[self cacheSomeSpriteBodies:[ENSPrance class] number:10];
		[self cacheSomeSpriteBodies:[LTWaddle class] number:10];
		[self cacheSomeSpriteBodies:[CDRBobble class] number:10];
		//[self cacheSomeSpriteBodies:[StationaryInvader class] number:10];
		[self cacheSomeSpriteBodies:[DynamicInvader class] number:10];
		[self cacheSomeSpriteBodies:[ShieldInvader class] number:10];
		
		// fetch settings
		appPList = [[NSMutableDictionary dictionaryWithDictionary:[Utils applicationPlistFromFile:@"appdata.plist"]] retain];	
		settings = [[SettingsManager alloc] init];
		
		if (![appPList objectForKey:@"settings"]) { 
			
			// first time launch

			// initialize player scores to 0
			[settings addIntFor: player[0].scoreKey init:0];
			[settings addIntFor: player[1].scoreKey init:0];

			[settings setMetaFor: player[0].scoreKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
			[settings setMetaFor: player[1].scoreKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
		
			// initialize player lastlevelscore to 0
			[settings addIntFor: player[0].lastLevelScoreKey init:0];
			[settings addIntFor: player[1].lastLevelScoreKey init:0];
			[settings setMetaFor: player[0].lastLevelScoreKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
			[settings setMetaFor: player[1].lastLevelScoreKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
			
			// initialize player chain to 0
			[settings addIntFor: player[0].chainKey init:0];
			[settings addIntFor: player[1].chainKey init:0];
			[settings setMetaFor: player[0].chainKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
			[settings setMetaFor: player[1].chainKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
			
			// initialize player maxchain to 0
			[settings addIntFor: player[0].maxChainKey init:0];
			[settings addIntFor: player[1].maxChainKey init:0];
			[settings setMetaFor: player[0].maxChainKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
			[settings setMetaFor: player[1].maxChainKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
			
			// initialize player lastLevelChain to 0
			[settings addIntFor: player[0].lastLevelChainKey init:0];
			[settings addIntFor: player[1].lastLevelChainKey init:0];
			[settings setMetaFor: player[0].lastLevelChainKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];
			[settings setMetaFor: player[1].lastLevelChainKey to:[NSDictionary dictionaryWithObjectsAndKeys:@"%@ points",  @"label", nil]];

			// initialize last level to 0
			[settings addIntFor:@"lastLevel" init:0];
			[settings setMetaFor:@"lastLevel" to:[NSDictionary dictionaryWithObjectsAndKeys:@"Last level played: %@",  @"label", nil]];
			
			// set player to not having logged in to OpenFeint upon first launch
			[settings addIntFor:@"OFwanted" init:0];
			[settings setMetaFor:@"OFwanted" to:[NSDictionary dictionaryWithObjectsAndKeys:@"OpenFeint acct status: %@",  @"label", nil]];
			
			// set scoreboards enabled
			[settings addIntFor:@"Scoreboards" init:1];
			[settings setMetaFor:@"Scoreboards" to:[NSDictionary dictionaryWithObjectsAndKeys:@"Scoreboards status: %@",  @"label", nil]];
			
			// count times run
			[settings addIntFor:@"TimesRun" init:0];
			[settings setMetaFor:@"TimesRun" to:[NSDictionary dictionaryWithObjectsAndKeys:@"App has been launched this many times: %@",  @"label", nil]];
			
			// track whether player has signed up for the koduco list when starting 10th game
			[settings addIntFor:@"SignedUp" init:0];
			[settings setMetaFor:@"SignedUp" to:[NSDictionary dictionaryWithObjectsAndKeys:@"Has user signed up for list: %@",  @"label", nil]];
			
			// SETTINGS V2 --------------------------------
			
			// allow selection of human/computer players
			[settings addOptionsFor:@"Player1Type" with:[NSArray arrayWithObjects:@"HUMAN", @"COMPUTER", nil] init:0];
			[settings addOptionsFor:@"Player2Type" with:[NSArray arrayWithObjects:@"HUMAN", @"COMPUTER", nil] init:0];
			
			// SETTINGS V3 --------------------------------
			
			// track settings version
			[settings addIntFor:@"SettingsVersion" init:3];

			// track if the tutorial has been played or not
			[settings addIntFor:@"TutorialPlayed" init:0];

			// have we asked player to review the game on start?
			[settings addIntFor:@"Reviewed" init:0];
			
			// have we asked player to review the game after winning a boss fight?
			[settings addIntFor:@"ReviewBoss" init:0];
			
			// have we asked player to review the game after 6 levels?
			[settings addIntFor:@"Review6" init:0];
			
			// have we asked player to review the game after 12 levels?
			[settings addIntFor:@"Review12" init:0];
			
			// track whether player has beaten a boss fight
			[settings addIntFor:@"BeatBoss" init:0];
			
			// have we asked player to signup on the list after beating 3 bosses?
			[settings addIntFor:@"Beat3SignUp" init:0];
			
			// has player beaten prologue?
			[settings addIntFor:@"BeatPrologue" init:0];
			
			// has player beaten episode one?
			[settings addIntFor:@"BeatEpOne" init:0];
			
			// has player beaten episode two?
			[settings addIntFor:@"BeatEpTwo" init:0];
			
			// last time ads were synced
			[settings addStringFor:@"LastAdSync" init:@""];
			
			// upgrade purchase
			[settings addStringFor:@"EpisodesProduct" init:@""];
			[settings addIntFor:@"EpisodesBought" init:0];
			
			[settings addIntFor:@"UnlockedEpOneNag" init:0];
			[settings addIntFor:@"UnlockedEpTwoNag" init:0];
			
		} else {
			[settings addSettingsFromPlistDict:[appPList objectForKey:@"settings"]];
			
			if (![settings exists:@"Player1Type"]) { // SETTINGS V2 --------------------------------
				// allow selection of human/computer players
				[settings addOptionsFor:@"Player1Type" with:[NSArray arrayWithObjects:@"HUMAN", @"COMPUTER", nil] init:0];
				[settings addOptionsFor:@"Player2Type" with:[NSArray arrayWithObjects:@"HUMAN", @"COMPUTER", nil] init:0];
			}
			if (![settings exists:@"TutorialPlayed"]) { // SETTINGS V3 --------------------------------
				[settings addIntFor:@"TutorialPlayed" init:0];
				[settings addIntFor:@"Reviewed" init:0];
				[settings addIntFor:@"ReviewBoss" init:0];
				[settings addIntFor:@"Review6" init:0];
				[settings addIntFor:@"Review12" init:0];
				[settings addIntFor:@"BeatBoss" init:0];
				[settings addIntFor:@"Beat3SignUp" init:0];
				[settings addIntFor:@"BeatPrologue" init:0];
				[settings addIntFor:@"BeatEpOne" init:0];
				[settings addIntFor:@"BeatEpTwo" init:0];
				[settings addIntFor:@"StartedEpOne" init:0];
				[settings addIntFor:@"StartedEpTwo" init:0];
				[settings addStringFor:@"LastAdSync" init:@""];
				[settings addStringFor:@"EpisodesProduct" init:@""];
				[settings addIntFor:@"EpisodesBought" init:0];
				[settings addIntFor:@"UnlockedEpOneNag" init:0];
				[settings addIntFor:@"UnlockedEpTwoNag" init:0];
			}
		}
		
		NSLog(@"%@",[settings get:player[0].scoreKey metaReplace:@"label"]);
		NSLog(@"%@",[settings get:player[1].scoreKey metaReplace:@"label"]);
//		[settings set:player[0].scoreKey toInt:0];
//		[settings set:player[1].scoreKey toInt:0];
		[settings set:@"Scoreboards" toInt:1];
		[settings inc:@"TimesRun" by:1];
		
		// setup tapzilla and openfeint
		
		[[ShakeDispatcher sharedInstance] addShakeListener:self];
		
		if([settings getInt:@"OFwanted"] == 1) {
			[self initOpenFeint];	
		}
		
		// init state
		
		gameBeat = NO;
		sentRequest = NO;
		soloInvader = false;
		bulletTime = false;
		bulletTimeDistance = _IPAD?200.0:100.0;
		
		physDt = -10;
		
		oldImpulse = b2Vec2(0,0);
		
		// restore adloader's last sync
		
		[[AdLoader sharedLoader] setLastSync:[settings get:@"LastAdSync"]];
		
		// check paid or free
		
		// if paid
		
		if ([settings getInt:@"EpisodesBought"] == 1) {
			if (_IPAD) {
				if ([Reachable connectedToNetwork] && [[AdLoader sharedLoader] needsSync]) {
					[[AdLoader sharedLoader] queryServer:ADQUERY_PAD_PAID];
				}
			}
			else {
				if ([Reachable connectedToNetwork] && [[AdLoader sharedLoader] needsSync]) {
					[[AdLoader sharedLoader] queryServer:ADQUERY_PHONE_PAID];
				}
			}
		}
		else {
			if (_IPAD) {
				if ([Reachable connectedToNetwork] && [[AdLoader sharedLoader] needsSync]) {
					[[AdLoader sharedLoader] queryServer:ADQUERY_PAD_FREE];
				}
			}
			else {
				if ([Reachable connectedToNetwork] && [[AdLoader sharedLoader] needsSync]) {
					[[AdLoader sharedLoader] queryServer:ADQUERY_PHONE_FREE];
				}
			}
		}		
		
		// should be the last line
		[self schedule: @selector(tick:)];
		
	}
	return self;
}

- (void) writeToPersist
{
	[appPList setObject:[settings toPlistDict] forKey:@"settings"];
	[settings set:@"LastAdSync" to: [[AdLoader sharedLoader] lastSyncStr]]; 
	[Utils writeApplicationPlist:(id) appPList toFile:@"appdata.plist"];
}


- (void) initOpenFeint {
	OFstarted = YES;
	
	ofDelegate = [CCOFDelegate new];
	
	NSDictionary* pvOFsettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:UIInterfaceOrientationPortrait], OpenFeintSettingDashboardOrientation, 
							  [NSNumber numberWithBool:NO], OpenFeintSettingEnablePushNotifications,
							  [NSNumber numberWithBool:YES], OpenFeintSettingDisableUserGeneratedContent,
								  [NSNumber numberWithBool:YES], OpenFeintSettingGameCenterEnabled, nil  ];
	
	[OpenFeint initializeWithProductKey:@"9QrMFwh45rH83PXgmx9WyA"
                              andSecret:@"KoFOPqjyEIthYgJzXiMZ25oJGoV4TC7qexlzesfTx4"
                         andDisplayName:@"PongVaders"
                            andSettings:pvOFsettings    // see OpenFeintSettings.h
                           andDelegates:[OFDelegatesContainer containerWithOpenFeintDelegate:ofDelegate]]; 
	
	myAchievementDelegate = [CCOFAchievementDelegate new];
	[OFAchievement setDelegate: myAchievementDelegate];
}

- (void) clearScene {
	[self retireParticles];
	[self clearBalls];
	[self clearInvaders];
	[self clearPowerups];
}

- (void) resetScene {
	self.position = ccp(0,0);
	oldImpulse = b2Vec2(0,0);
	[planet[0] reset];
	[planet[1] reset];
	[starfield reset];
	
	soloInvader = false;
	[fuzz stop];
	
	bulletTimeDistance = _IPAD?200.0:100.0;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc {
	// destroy any remaining invaders in the cache
	for (NSMutableArray *invarray in [inactiveInvaders allValues]) {
		for (Invader *invader in invarray) {
			// remove from world
			world->DestroyBody(invader.b2dBody);
		}
		[invarray release];
	}
	[inactiveInvaders release];

	[fleets release];
	[activeParticles release];
	[inactiveParticles release];
	[touchedSprites release];
	
	// delete box2d stuff
	delete world;
	delete _contactListener;
	delete m_debugDraw;
	
	// PongVader scene stuff
	world = NULL;
	paddle1 = NULL;
	paddle2 = NULL;
	
	[effectring release];
	[effectringanim release];
	
	// settings, players and other game level stuff
	[player[0] release];
	[player[1] release];
	[settings release];
	
	// don't forget to call "super dealloc"
	[super dealloc];
	_globalSceneInst = nil;
}

/*
-(void) draw {
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	//world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
}
*/

#pragma mark internal entity management routines ----------------------------

- (void) addParticleAt: (CGPoint) pos particleType: (int) ptype {
	NSString *partType=nil;
	
	if (_IPAD) {
		switch(ptype) {
			case 1: partType = [NSString stringWithString:@"mine-explosion.plist"]; break;
			case 2:	partType = [NSString stringWithString:@"smallExplosion.plist"]; break;
			case 3: partType = [NSString stringWithString:@"powerupParticle.plist"]; break;
		}
	}
	else {
		switch(ptype) {
			case 1: partType = [NSString stringWithString:@"mine-explosion-iphone.plist"]; break;
			case 2:	partType = [NSString stringWithString:@"smallExplosion-iphone.plist"]; break;
			case 3: partType = [NSString stringWithString:@"powerupParticle.plist"]; break;
		}
	}

	
	NamedParticleSystem *ps = nil;
	NSMutableArray *array = [inactiveParticles objectForKey:partType];
	if ([array count] == 0) {
		ps = [[NamedParticleSystem particleWithFile:partType] retain];
	} else {
		ps = [[array objectAtIndex:0] retain];
		[array removeObjectAtIndex:0];
	}
	
	[activeParticles addObject:ps];
	ps.position = pos;
	[self addChild: ps];
	[ps release];
	
	//	CCParticleSystem *p; 
	//	if ([inactiveParticles count]) {
	//		p = [[inactiveParticles objectAtIndex:0] retain];
	//		[inactiveParticles removeObject:p];
	//	} else {
	//		p = [[NamedParticleSystem particleWithFile:partType] retain];
	//	}

}

- (void) retireParticles {
	NSMutableArray *retiring = [[NSMutableArray alloc] initWithCapacity:10];
	
	for (NamedParticleSystem *p in activeParticles) {
		if (!p.active && !p.particleCount) {
			
			[retiring addObject:p];
			
			[p resetSystem];
			
			NSMutableArray *array = [inactiveParticles objectForKey:p.pFile];
			if (array == nil) {
				array = [NSMutableArray array];
				[inactiveParticles setObject: array forKey:p.pFile];
			}
			[array addObject:p];	
			
			// TODO: make this cleanup:YES 
			[self removeChild:p cleanup:NO];
		}
	}
	
	for (NamedParticleSystem *p in retiring) 
	{
		[activeParticles removeObject:p];
	}
	
	[retiring release];
}

- (void) cacheSomeParticles: (NSString *) pType number: (int) num {
	NamedParticleSystem *ps = nil;
	NSMutableArray *array = [inactiveParticles objectForKey:pType];
	for (int i=0; i<num; i++) 
	{
		// create and add to world. Note they start off deactivated
		ps = [NamedParticleSystem particleWithFile:pType];
		
		// add to inactive cache
		if (array == nil) {
			array = [NSMutableArray array];
			[inactiveParticles setObject: array forKey:pType];
		}
		[array addObject:ps];
	}
}


- (void) paddleContact: (Paddle*) p withBall: (Ball*) b {
	
	//NSLog(@"paddle: %@ contact with ball: %@", p, b);
	
	// destroy ball if paddle is in POW_STAT red state
	if (p.state == POW_STAT) {
		[b doKill];
		[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];
		return;
	}
	
	// attach player to ball, and give player a score boost
	// also do hit on ball
	
	BOOL actualHit = NO;
	if ([b doHit:p.player]) {
		[p.player incScoreBy:SCORE_REBOUNDBALL];
		[b resetCombo];
		[p.player incChain];
		actualHit = YES;
	}
	
	// check to see if the ball has already passed the paddle's bounds, if so skip
	// the following section that sets ball's angle
	
	//if ((p.position.y > 500) && ((b.position.y+b.contentSize.height/2.0) > (p.position.y - p.contentSize.height/2.0)))
//		return;
//
//	if ((p.position.y < 500) && ((b.position.y-b.contentSize.height/2.0) < (p.position.y + p.contentSize.height/2.0)))
//		return;
	
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	/*
	// more tight control over bounds
	if ((p.position.y > (ssz.height/2)) && ((b.position.y) > (p.position.y + p.contentSize.height/2.0)))
		return;
	
	if ((p.position.y < (ssz.height/2)) && ((b.position.y) < (p.position.y - p.contentSize.height/2.0)))
		return;
	 
	 */
	
	float paddlesize;
	
	if (p.state == SHRINK) {
		paddlesize = PADDLE_DEFAULT_WIDTH/PADDLE_SCALE;
	}
	if (p.state == EXTEND) {
		paddlesize = PADDLE_DEFAULT_WIDTH*PADDLE_SCALE;
	}
	else {
		paddlesize = PADDLE_DEFAULT_WIDTH;
	}
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		paddlesize = paddlesize/2.0;
	}
	
	float paddlePosition = b.position.x - p.position.x + (paddlesize/2);
	b2Vec2 ballVelocity = b.b2dBody->GetLinearVelocity();
	float magnitude = ballVelocity.Length()*1.1;
	float angle; 

	
	if (p.position.y > ssz.height/2.0) { 
		angle = 245 - (((float)paddlePosition/paddlesize) * 130);
	}
	else {
		angle = 115 + (((float)paddlePosition/paddlesize) * 130) + 180;
	}
	
	b.b2dBody->SetLinearVelocity(b2Vec2(magnitude*sin(RADIANS(angle)),magnitude*cos(RADIANS(angle))));	
	

//	if (p.state != POW_LTWADDLE) {
//		[[SimpleAudioEngine sharedEngine] playEffect:@"redpaddle.wav"];
//	}
	
	// if paddle is in POW_LTWADDLE state, spawn another, faster ball
	if (p.state == POW_LTWADDLE && actualHit && ![b isDead]) {
		Ball *newball;
		if (p.position.y > (ssz.height/2)) { 
			newball = (Ball *) [Ball spriteBodyAt:ccp(b.position.x, b.position.y - (b.contentSize.width) - 5) withForce: ccp(0,0) inWorld:world];
		}
		else {
			newball = (Ball *) [Ball spriteBodyAt:ccp(b.position.x, b.position.y + (b.contentSize.width) + 5) withForce: ccp(0,0) inWorld:world];
		}
		
		newball.b2dBody->SetLinearVelocity(b2Vec2(1.1*magnitude*sin(RADIANS(angle)),1.1*magnitude*cos(RADIANS(angle))));
		[newball doHit:p.player];
		if ([b isHot]) {
		[newball makeFireball];
		}
		[self addChild:newball];
		[balls addObject:newball];	
		[[SimpleAudioEngine sharedEngine] playEffect:@"slice.wav"];
	}
	
}

- (void) paddleContact: (Paddle*) p withDyn: (DynamicInvader*) b {
	
	NSLog(@"paddle: %@ contact with mine: %@", p, b);
	CGSize ssz = [CCDirector sharedDirector].winSize;
	
	float paddlesize;
	
	if (p.state == SHRINK) {
		paddlesize = PADDLE_DEFAULT_WIDTH/PADDLE_SCALE;
	}
	if (p.state == EXTEND) {
		paddlesize = PADDLE_DEFAULT_WIDTH*PADDLE_SCALE;
	}
	else {
		paddlesize = PADDLE_DEFAULT_WIDTH;
	}
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		paddlesize = paddlesize/2.0;
	}
	
	float paddlePosition = b.position.x - p.position.x + (paddlesize/2);
	b2Vec2 ballVelocity = b.b2dBody->GetLinearVelocity();
	float magnitude = ballVelocity.Length()*1.1;
	float angle; 
	
	
	if (p.position.y > ssz.height/2.0) { 
		angle = 245 - (((float)paddlePosition/paddlesize) * 130);
	}
	else {
		angle = 115 + (((float)paddlePosition/paddlesize) * 130) + 180;
	}
	
	b.b2dBody->SetLinearVelocity(b2Vec2(magnitude*sin(RADIANS(angle)),magnitude*cos(RADIANS(angle))));		
}

- (void) paddleContact: (Paddle*) p withPowerup: (Powerup*) pow {
	// if paddle is computer, return
	if (![[GameState getCurrentState] isKindOfClass: [StateMovie class]] && 
		((p == paddle1 && [[settings get:@"Player1Type"] isEqualToString:@"COMPUTER"]) ||
		(p == paddle2 && [[settings get:@"Player2Type"] isEqualToString:@"COMPUTER"]))) {
		[pow doKill];
		[self addParticleAt:ccp(pow.position.x, pow.position.y) particleType:PART_POW];
		return;
	}
	
	// else kill powerup and play sounds and make effects
	else {
		[pow doKill];
		[[SimpleAudioEngine sharedEngine] playEffect:@"powerup.wav"];
		[self addParticleAt:ccp(pow.position.x, pow.position.y) particleType:PART_POW];
		
		[p reset];
		
		[p.player incScoreBy:SCORE_GETPOWERUP];
		
		p.state = pow.state;
		p.stateRemaining = 10;
		[p tintEffect:pow.state];
		
		if (p.state == POW_ENSPRANCE) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"expand.wav"];
			[p extend];

//			shrinkage disabled
//
//			if (p == paddle1) {
//				[paddle2 shrink];
//			}
//			else {
//				[paddle1 shrink];
//			}

		}
	}
}

- (void) destroyBalls {
	NSMutableArray *destroyedBalls = [[NSMutableArray alloc] init];

	for (Ball *ball in balls) {
		if ([ball isDead]) {
			//[ball reset];
			[destroyedBalls addObject:ball];	
		}
	}
	
	if ([destroyedBalls count] > 0)	[[SimpleAudioEngine sharedEngine] playEffect:@"boom.wav"];		
	
	for (Ball *deadBall in destroyedBalls) {
		[self addParticleAt:ccp(deadBall.position.x, deadBall.position.y) particleType:PART_BALL];

		// remove from world
		world->DestroyBody(deadBall.b2dBody);
		
		// cleanup ball (ribbons)
		[deadBall cleanup];
		//NSLog(@"Destroyed ball %@, %d%@", deadBall, [balls count], [deadBall isHot]?@", Fireball": @"");

		// remove from scene
		[self removeChild:deadBall cleanup:YES];
		
		[balls removeObject: deadBall];		
	}
	[destroyedBalls release];
}

- (void) clearBalls {
	for (Ball *ball in balls) {
		[ball doKill];	
	}
	
	[self destroyBalls];
}

- (void) clearPowerups {
	for (Powerup *pow in powerups) {
		[pow doKill];	
	}
	
	[self destroyPowerups];
	[paddle1 reset];
	[paddle2 reset];
}

- (void) destroyPowerups {
	NSMutableArray *destroyedPowerups = [[NSMutableArray alloc] init];
	
	for (Powerup *pow in powerups) {
		if ([pow isDead]) {
			[destroyedPowerups addObject:pow];	
		}
	}
	
	for (Ball *deadPow in destroyedPowerups) {
		
		// remove from world
		world->DestroyBody(deadPow.b2dBody);
		
		// remove from scene
		[self removeChild:deadPow cleanup:YES];
		
		[powerups removeObject: deadPow];
	}
	[destroyedPowerups release];
}

- (void) destroyInvader: (SpriteBody<Shooter> *) deadInvader inGame: (BOOL) ingame {
	if (ingame) {
		
		// spawn particles (only if its a dynamic invader)
		if ([deadInvader isMemberOfClass:[DynamicInvader class]]) [self addParticleAt:ccp(deadInvader.position.x, deadInvader.position.y) particleType: PART_DYN];
		
		// make sound
		[[SimpleAudioEngine sharedEngine] playEffect:@"warp.wav"];	
		
		// spawn powerup of appropriate type
		
		int effect=0;
		int powerupChance = [[GameState getCurrentState] getPowerupChance];
		if ([[GameState getCurrentState] isKindOfClass:[StatePlaying class]] &&
			([[settings get:@"Player1Type"] isEqualToString:@"HUMAN"] || [[settings get:@"Player2Type"] isEqualToString:@"HUMAN"]) && 
			(arc4random() % 100 <= powerupChance) && ![deadInvader isMemberOfClass:[DynamicInvader class]] &&
			(effect = [[GameState getCurrentState] getPowerup]) != 0) {
			
			// spawn powerups based on dead invader class? NO, but good idea
			
			CGPoint dir;
			float magnitude;
			
			if (_IPAD) {
				magnitude = 2;
			}
			else {
				magnitude = .25;
			}
			
			if (arc4random() % 2 == 0) {
				dir = [[settings get:@"Player1Type"] isEqualToString:@"HUMAN"]?ccp(0,-magnitude):ccp(0,0);
			}
			else {
				dir = [[settings get:@"Player2Type"] isEqualToString:@"HUMAN"]?ccp(0,magnitude):ccp(0,0);
			}
			
			if (!bulletTime && (dir.y != 0)) {
				Powerup *powerup = (Powerup *) [Powerup spriteBodyAt:ccp(deadInvader.position.x, deadInvader.position.y) withEffect: effect withForce:dir inWorld:world];
				[self addChild:powerup];
				[powerups addObject:powerup];
			}
		}
		
		// display pop animation
		if (deadInvader.pop) {
			CCSequence *popAction = [CCSequence actions:
									 [CCAnimate actionWithAnimation:deadInvader.pop restoreOriginalFrame:NO],
									 [CCCallFuncN actionWithTarget:self selector:@selector(cleanupInvader:)], nil];
			[deadInvader runAction: popAction];
		} 
		
		// we only cleanup invaders that have a death-anim in game. All other invaders won't be cleaned up until switching
		// levels, when it will be called with ingame=NO (otherwise, boss1 will get cleaned up and won't be around for 
		// the outro)
		//else {
		//	[self cleanupInvader:deadInvader];
		//}
		
		if ([deadInvader isKindOfClass:[DynamicInvader class]] ||
			[deadInvader isKindOfClass:[ADMBrainSeg class]] || 
			[deadInvader isKindOfClass:[ADMBrainTail class]] ) { 
			[self cleanupInvader:deadInvader]; 
		}
	} 
	else /* not ingame */ {
		[self cleanupInvader:deadInvader];
	}
	
	// deactivate 
	deadInvader.b2dBody->SetActive(NO);
}

- (void) cleanupInvader: (SpriteBody<Shooter> *) deadInvader
{
	[deadInvader cleanupSpriteBody];
	
	// remove from fleet
	for (Fleet *fleet in fleets) {
		[fleet removeInvader:deadInvader];
	}
	
	// remove from scene
	[self.sheet removeChild:deadInvader cleanup:YES];	
	
	// TODO: reset invader before adding back to cache
	[deadInvader reset];
	
	// add to inactive cache
	NSMutableArray *array = [inactiveInvaders objectForKey:[[deadInvader class] description]];
	if (array == nil) {
		array = [NSMutableArray array];
		[inactiveInvaders setObject: array forKey:[[deadInvader class] description]];
	}
	[array addObject:deadInvader];		
}

- (void) destroyInvaders {
	NSMutableArray *destroyedInvaders = [[NSMutableArray alloc] init];
	
	for (Fleet *fleet in fleets) {
		for (SpriteBody<Shooter> *invader in fleet.invaders) {
			if ([invader isDead] && invader.b2dBody->IsActive()) {
				[destroyedInvaders addObject:invader];
			}
			if ([invader isDead] && [invader isMemberOfClass:[DynamicInvader class]]) {
				[destroyedInvaders addObject:invader];
			}
		}
	}
	
	for (SpriteBody *deadInvader in destroyedInvaders) {
		[self destroyInvader: deadInvader inGame: YES];
	}
	
	[destroyedInvaders release];

	// remove dead fleets
	
	NSMutableArray *deadfleets = [[NSMutableArray alloc] init];

	for (Fleet *fleet in fleets) {
		if ([fleet.invaders count] == 0 && fleet.numNukes == 0)
			[deadfleets addObject:fleet];
	}
	
	[fleets removeObjectsInArray:deadfleets];
	[deadfleets release];
}

- (void) clearInvaders {
	NSMutableArray *destroyedInvaders = [[NSMutableArray alloc] init];
	
	for (Fleet *fleet in fleets) {
		for (SpriteBody<Shooter> *invader in fleet.invaders) {
			[destroyedInvaders addObject:invader];
		}
	}
	
	for (SpriteBody *deadInvader in destroyedInvaders) {
		[self destroyInvader: deadInvader inGame: NO];
	}
	
	[destroyedInvaders release];
	
	// remove dead fleets
	[fleets removeAllObjects];
}


- (void) cacheSomeSpriteBodies: (Class) spriteBodyClass number: (int) num {
	SpriteBody *sb = nil;
	NSMutableArray *array = [inactiveInvaders objectForKey:[spriteBodyClass description]];
	for (int i=0; i<num; i++) 
	{
		// create and add to world. Note they start off deactivated
		sb = [spriteBodyClass spriteBodyAt: ccp(0,0) withForce:ccp(0,0) inWorld: world];
		
		// add to inactive cache
		if (array == nil) {
			array = [NSMutableArray array];
			[inactiveInvaders setObject: array forKey:[spriteBodyClass description]];
		}
		[array addObject:sb];
	}
}

- (void) addBounceToBallAt: (CGPoint) pos with: (id) hitWhat {
	
}

#pragma mark dispatch events to current state --------------------------------

-(void) tick: (ccTime) dt {	
	[GameState handleEvent:[[GameState getCurrentState] timer:dt]];
	
//	if (physDt < 0) {
//		physDt += 1;
//	}
//	else if (physDt == 0) {
//		physDt = dt;
//	}
//	else {
//		physDt = physDt * .99 +	dt*(1-.99);
//	}
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[GameState handleEvent:[[GameState getCurrentState] startTouch:touches withEvent:event]];
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[GameState handleEvent:[[GameState getCurrentState] endTouch:touches withEvent:event]];
}
- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[GameState handleEvent:[[GameState getCurrentState] drag:touches withEvent:event]];
}

#pragma mark scene event handlers, these are called from current GameState -------

-(void) doTick: (ccTime) dot {	
	//ccTime dt = physDt;
	
	ccTime dt = dot;
	
	if (dt <= 0) {
		return;	
	}
	
	//printf("dt: %f \n", dot);
	
//	int32 velocityIterations = 8;
//	int32 positionIterations = 1;

	CGSize ssz = [CCDirector sharedDirector].winSize;
	
//	int32 velocityIterations = 10;
//	int32 positionIterations = 10;
	
	int32 velocityIterations = 5;
	int32 positionIterations = 1;
	
	bulletTime = false;
	
	// check if bullettime should be entered
	// check if there is only one fleet which is still alive

	
	int fleetsAlive = 0;
	Fleet *lastFleet;
	
	for (Fleet *f in fleets) {
		if (![f isDead]) {
			fleetsAlive += 1;	
			lastFleet = f;
		}
	}
	
	
	if (!bossTime && !soloInvader && (fleetsAlive == 1)) {
		if ([[lastFleet getInvadersThatCount] count] == 1) {
			soloInvader = true;	
			// fade out bg music
			id action = [CCPropertyAction actionWithDuration:MUSIC_FADE_TIME_BULLET key:@"BackgroundVolume" from:1.0 to:0.0];
			[self runAction:action];
			
			fuzz.gain = .2;
			[fuzz play];
		}
	}
	
	// from that fleet, return an invader that counts
	// if yes, check if ball within bullet time distance
	
	if (frozen) {
		bulletTime = YES;
	}

	if (soloInvader || frozen) {
		Invader *lastInvader = [[lastFleet getInvadersThatCount] lastObject];
		for (Ball *ball in balls) {
			b2Filter ballFilter = ball.b2dBody->GetFixtureList()->GetFilterData();
			if (ballFilter.maskBits == (0xFFFF & ~COL_CAT_BALL) && [PongVader spriteDistance: ball sprite2: lastInvader] < bulletTimeDistance) {
				bulletTime = true;	
				[ball enterBulletTime];
			}
			else {
				[ball exitBulletTime];
			}
		}
		
		if (bulletTime) {
			
			// draw effect
			effectring.visible = YES;
			effectring.position = lastInvader.position;
			
			Ball *nearestBall;
			float dist = 10000;
			
			for (Ball *ball in balls) {
				float ndist = [Utils distanceFrom:ball.position to:lastInvader.position];
				
				if ((ndist < dist)) 
				{
					nearestBall = ball;
					dist = ndist;
				}
			}
			
			// float dist = [Utils distanceFrom:nearestBall.position to:lastInvader.position];
			
			if (_IPAD) {
				if (dist <= .75*bulletTimeDistance) {
					innerBulletRadius = YES;
				}
				else {
					innerBulletRadius = NO;
				}
			}
			else {
				if (dist <= .75*bulletTimeDistance) {
					innerBulletRadius = YES;
				}
				else {
					innerBulletRadius = NO;
				}
			}
			
			fuzz.gain = .2 + (1.5*(1-(dist/bulletTimeDistance))) * (1.5*(1-(dist/bulletTimeDistance)));
			
			//printf("dist: %f, gain: %f \n", dist, fuzz.gain);
		}
	}
	
	if (!bulletTime) {
		fuzz.gain = .2;	
		oldImpulse = b2Vec2(0,0);
		effectring.visible = NO;
	}
	
	
	
	
// why doesn't this work?
//	if ([fleets count] == 1 && [[fleets lastObject].invaders count] == 1) {
//		
//	}

	
	
	// Instruct the world to perform a single step of simulation.
	if (bulletTime) {
		dt = dt*BULLETTIME;
	}
	
	world->Step(dt, velocityIterations, positionIterations);

	//Iterate over the bodies in the physics world & tick
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())	{
		if ((b->GetUserData() != NULL) && b->IsActive()) {
			SpriteBody *myActor = (SpriteBody*)b->GetUserData();
			[myActor tick: dt];
		}	
	}
	
//	world->Step(.05, velocityIterations, positionIterations);
//	
//	//Iterate over the bodies in the physics world & tick
//	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())	{
//		if ((b->GetUserData() != NULL) && b->IsActive()) {
//			SpriteBody *myActor = (SpriteBody*)b->GetUserData();
//			[myActor tick: .05];
//		}	
//	}
	
	
	// Check paddle state
	if (paddle1.state > 0) {
		
		// decrement counter for paddle state if non-normal
		paddle1.stateRemaining -= dt;
		if (paddle1.stateRemaining <= 0) {
			[paddle1 reset];
		}
		
		// generate balls if paddle has POW_CDRBOBBLE powerup
		if (paddle1.state == POW_CDRBOBBLE) {
			paddle1.lastShot +=dt;
			
			if (paddle1.lastShot >= 1) {
				paddle1.lastShot = 0;
				Ball *newball = (Ball *) [Ball spriteBodyAt:ccp(paddle1.position.x, paddle1.position.y + paddle1.contentSize.height + 2) withForce: ccp(0,5) inWorld:world];
				[newball makeFireball];
				newball.lastPlayer = paddle1.player;
				[self addChild:newball];
				[balls addObject:newball];
				[[SimpleAudioEngine sharedEngine] playEffect:@"greenshot.wav"];
			}
		}
	}
	
	if (paddle2.state > 0) {
		paddle2.stateRemaining -= dt;
		if (paddle2.stateRemaining <= 0) {
			[paddle2 reset];
		}
		
		// generate balls if paddle has POW_CDRBOBBLE powerup
		if (paddle2.state == POW_CDRBOBBLE) {
			paddle2.lastShot +=dt;
			
			if (paddle2.lastShot >= 1) {
				paddle2.lastShot = 0;
				Ball *newball = (Ball *) [Ball spriteBodyAt:ccp(paddle2.position.x, paddle2.position.y - paddle1.contentSize.height - 2) withForce: ccp(0,-5) inWorld:world];
				[newball makeFireball];
				newball.lastPlayer = paddle2.player;
				[self addChild:newball];
				[balls addObject:newball];
				[[SimpleAudioEngine sharedEngine] playEffect:@"greenshot.wav"];
			}
		}
	}
	
	//printf("________#contacts: %d\n", (int) _contactListener->_contacts.size());

	std::vector<Contact>::iterator pos;
	for(pos = _contactListener->_contacts.begin(); 
		pos != _contactListener->_contacts.end(); ++pos) {
		Contact contact = *pos;
		
		// check for ball hitting top or bottom
		
		NSObject *objA = (NSObject *) contact.fixtureA->GetBody()->GetUserData();
		NSObject *objB = (NSObject *) contact.fixtureB->GetBody()->GetUserData();
		
		if (contact.fixtureA == topFixture && [objB class]  == [Ball class]) {
			Ball *b = (Ball*) objB;
			//[destroyedBalls addObject:b];					
			[b doKill];
			//[self addParticleAt:ccp(b.position.x,b.position.y) particleType:PART_BALL];			
			if (!planet[1].shaking) {
				[planet[1] doHit];
				[starfield doDrift];
				[paddle2.player incScoreBy:SCORE_PLANETHIT];
				[paddle2.player resetChain];
			}
		}
		else if ([objA class]  == [Ball class] && contact.fixtureB == topFixture) {
			Ball *b = (Ball*) objA;
			[b doKill];
			//[self addParticleAt:ccp(b.position.x,b.position.y) particleType:PART_BALL];
			if (!planet[1].shaking) {
				[planet[1] doHit];
				[starfield doDrift];
				[paddle2.player incScoreBy:SCORE_PLANETHIT];
				[paddle2.player resetChain];
			}
		}
		else if (contact.fixtureA == bottomFixture && [objB class]  == [Ball class]) {
			Ball *b = (Ball*) objB;
			[b doKill];
			//[self addParticleAt:ccp(b.position.x,b.position.y) particleType:PART_BALL];
			if (!planet[0].shaking) {
				[planet[0] doHit];
				[starfield doDrift];
				[paddle1.player incScoreBy:SCORE_PLANETHIT];
				[paddle1.player resetChain];
			}
		}
		else if ([objA class]  == [Ball class] && contact.fixtureB == bottomFixture) {
			Ball *b = (Ball*) objA;
			[b doKill];
			//[self addParticleAt:ccp(b.position.x,b.position.y) particleType:PART_BALL];
			if (!planet[0].shaking) {
				[planet[0] doHit];
				[starfield doDrift];
				[paddle1.player incScoreBy:SCORE_PLANETHIT];
				[paddle1.player resetChain];
			}
		}
		
		// check for ball hitting sides
		
		if (contact.fixtureA == leftFixture && [objB class]  == [Ball class]) {
			Ball *b = (Ball*) objB;
			[b addBounceAgainst:nil];
		}
		else if ([objA class]  == [Ball class] && contact.fixtureB == leftFixture) {
			Ball *b = (Ball*) objA;
			[b addBounceAgainst:nil];
		}
		else if (contact.fixtureA == rightFixture && [objB class]  == [Ball class]) {
			Ball *b = (Ball*) objB;
			[b addBounceAgainst:nil];
		}
		else if ([objA class]  == [Ball class] && contact.fixtureB == rightFixture) {
			Ball *b = (Ball*) objA;
			[b addBounceAgainst:nil];
		}
		
		// check for collision with invader
		// note that hitting anything null will give an exception; make sure none of those will give
		// null ever
		
		else if ([objA isMemberOfClass:[Ball class]] && ([objB isKindOfClass:[Invader class]] || [objB isMemberOfClass:[DynamicInvader class]])) {
			SpriteBody<Shooter> *invader = (SpriteBody<Shooter> *) objB;
			Ball *ball = (Ball *) objA;
			if ([ball doHit:invader]) {
				if (([invader doHitFrom: ball withDamage: [ball isHot]?10:1]) /* && [invader isBoss]) || ![ball isHot]*/) {
					[ball doKill];
				} 
			}
				 //[destroyedInvaders addObject:(SpriteBody*) objB];
		}
			
		else if	([objB isMemberOfClass:[Ball class]] && ( [objA isKindOfClass:[Invader class]] || [objA isMemberOfClass:[DynamicInvader class]])) {
			SpriteBody<Shooter> *invader = (SpriteBody<Shooter> *) objA;
			Ball *ball = (Ball *) objB;
			if ([ball doHit:invader]) {
				if (([invader doHitFrom: ball withDamage: [ball isHot]?10:1]) /*&& [invader isBoss]) || ![ball isHot]*/) {
					[ball doKill];
				} 
			}
		}
		
		// check for collision with rocks
		
		else if ([objA isMemberOfClass:[Ball class]] && ([objB isKindOfClass:[Rock class]])) {
			SpriteBody<Shooter> *invader = (SpriteBody<Shooter> *) objB;
			Ball *ball = (Ball *) objA;
			[ball addBounceAgainst:invader];
		}
		
		else if	([objB isMemberOfClass:[Ball class]] && ( [objA isKindOfClass:[Rock class]])) {
			SpriteBody<Shooter> *invader = (SpriteBody<Shooter> *) objA;
			Ball *ball = (Ball *) objB;
			[ball addBounceAgainst:invader];
		}
		
		// check for ball collision with paddle
		// apply force appropriately
		
		else if ([objA isMemberOfClass:[Ball class]] && [objB isMemberOfClass:[Paddle class]]) {
			[self paddleContact:(Paddle *) objB withBall:(Ball *) objA];
		}
		
		else if	([objB isMemberOfClass:[Ball class]] && [objA isMemberOfClass:[Paddle class]]) {
			[self paddleContact:(Paddle *) objA withBall:(Ball *) objB];
		}
		
		// check for general spritebody collision and do hit on ball
		/*
		else if ([objA isMemberOfClass:[Ball class]] && 
				 [objB isKindOfClass:[SpriteBody class]]) {
			Ball *ball = (Ball *) objA;
			[ball doHit:(SpriteBody *)objB];
		}
		
		else if	([objB isMemberOfClass:[Ball class]] && 
				 [objA isKindOfClass:[SpriteBody class]]) {
			Ball *ball = (Ball *) objB;
			[ball doHit:(SpriteBody *)objA];
		}
		*/
		
		// handle dynamic invader contact
		
		// with invaders
		else if([objA isMemberOfClass:[DynamicInvader class]] && [objB isKindOfClass:[Invader class]]) {
			DynamicInvader *dyn = (DynamicInvader *) objA;
			[self doExplosionAt:ccp(dyn.position.x, dyn.position.y) fromDyn:dyn];
		}
		
		else if([objA isKindOfClass:[Invader class]] && [objB isMemberOfClass:[DynamicInvader class]]) {
			DynamicInvader *dyn = (DynamicInvader *) objB;
			[self doExplosionAt:ccp(dyn.position.x, dyn.position.y) fromDyn:dyn];
		}
		
		//else if([(SpriteBody*) contact.fixtureA->GetBody()->GetUserData() isKindOfClass:[Invader class]] &&
//				[(SpriteBody*) contact.fixtureB->GetBody()->GetUserData() isMemberOfClass:[DynamicInvader class]]) {
//			DynamicInvader *invader = (DynamicInvader *) contact.fixtureB->GetBody()->GetUserData();
//			[self doExplosionAt:ccp(invader.position.x, invader.position.y) fromDyn:invader];
//		}
		
		// with paddle -- accelerate
		else if([objA isKindOfClass:[Paddle class]] && [objB isMemberOfClass:[DynamicInvader class]]) {
			DynamicInvader *dyn = (DynamicInvader *) objB;
			Paddle *paddle = (Paddle*) objA;
			//[self doExplosionAt:ccp(dyn.position.x, dyn.position.y) fromDyn:dyn];
			[self paddleContact:paddle withDyn:dyn];
		}
		else if([objA isKindOfClass:[DynamicInvader class]] && [objB isMemberOfClass:[Paddle class]]) {
			DynamicInvader *dyn = (DynamicInvader *) objA;
			Paddle *paddle = (Paddle*) objB;
			//[self doExplosionAt:ccp(dyn.position.x, dyn.position.y) fromDyn:dyn];
			[self paddleContact:paddle withDyn:dyn];
	
		}
		
		// with planets
		if (contact.fixtureA == topFixture && [objB class]  == [DynamicInvader class]) {
			DynamicInvader *dyn = (DynamicInvader *) objB;
			[self doExplosionAt:ccp(dyn.position.x, dyn.position.y) fromDyn:dyn];
			
			if (!planet[1].shaking) {
				[planet[1] doHit];
				[starfield doDrift];
				[paddle2.player incScoreBy:SCORE_PLANETHIT];
				[paddle2.player resetChain];
			}
		}
		else if ([objA class]  == [DynamicInvader class] && contact.fixtureB == topFixture) {
			DynamicInvader *dyn = (DynamicInvader *) objA;
			[self doExplosionAt:ccp(dyn.position.x, dyn.position.y) fromDyn:dyn];
			
			if (!planet[1].shaking) {
				[planet[1] doHit];
				[starfield doDrift];
				[paddle2.player incScoreBy:SCORE_PLANETHIT];
				[paddle2.player resetChain];
			}
		}
		else if (contact.fixtureA == bottomFixture && [objB class]  == [DynamicInvader class]) {
			DynamicInvader *dyn = (DynamicInvader *) objB;
			[self doExplosionAt:ccp(dyn.position.x, dyn.position.y) fromDyn:dyn];
			
			if (!planet[0].shaking) {
				[planet[0] doHit];
				[starfield doDrift];
				[paddle1.player incScoreBy:SCORE_PLANETHIT];
				[paddle1.player resetChain];
			}
		}
		else if ([objA class]  == [DynamicInvader class] && contact.fixtureB == bottomFixture) {
			DynamicInvader *dyn = (DynamicInvader *) objA;
			[self doExplosionAt:ccp(dyn.position.x, dyn.position.y) fromDyn:dyn];
			
			if (!planet[0].shaking) {
				[planet[0] doHit];
				[starfield doDrift];
				[paddle1.player incScoreBy:SCORE_PLANETHIT];
				[paddle1.player resetChain];
			}
		}
		
		// check for powerup hitting top or bottom
		
		else if (contact.fixtureA == topFixture && [(SpriteBody*) contact.fixtureB->GetBody()->GetUserData() class]  == [Powerup class]) {
			Powerup *pow = (Powerup*) contact.fixtureB->GetBody()->GetUserData();				
			[pow doKill];
		}
		else if ([(SpriteBody*) contact.fixtureA->GetBody()->GetUserData() class]  == [Powerup class] && contact.fixtureB == topFixture) {
			Powerup *pow = (Powerup*) contact.fixtureA->GetBody()->GetUserData();
			[pow doKill];
		}
		else if (contact.fixtureA == bottomFixture && [(SpriteBody*) contact.fixtureB->GetBody()->GetUserData() class]  == [Powerup class]) {
			Powerup *pow = (Powerup*) contact.fixtureB->GetBody()->GetUserData();
			[pow doKill];
		}
		else if ([(SpriteBody*) contact.fixtureA->GetBody()->GetUserData() class]  == [Powerup class] && contact.fixtureB == bottomFixture) {
			Powerup *pow = (Powerup*) contact.fixtureA->GetBody()->GetUserData();
			[pow doKill];
		}
		
		// check for powerup collision with paddle
		
		else if ([(SpriteBody*) contact.fixtureA->GetBody()->GetUserData() isMemberOfClass:[Powerup class]] && 
				 [(SpriteBody*) contact.fixtureB->GetBody()->GetUserData() isMemberOfClass:[Paddle class]]) {
			[self paddleContact:(Paddle *) contact.fixtureB->GetBody()->GetUserData() 
					withPowerup:(Powerup *) contact.fixtureA->GetBody()->GetUserData()];
		}
		
		else if	([(SpriteBody*) contact.fixtureB->GetBody()->GetUserData() isMemberOfClass:[Powerup class]] && 
				 [(SpriteBody*) contact.fixtureA->GetBody()->GetUserData() isMemberOfClass:[Paddle class]]) {
			[self paddleContact:(Paddle *) contact.fixtureA->GetBody()->GetUserData() 
					withPowerup:(Powerup *) contact.fixtureB->GetBody()->GetUserData()];
		}
	}
	
	// check for balls that have gone out of bounds
	// apply strobe effect if ball is approaching a paddle
	
	for (Ball *ball in balls) {
		[ball updateRibbon:dt];
		
		if ([ball isWhite] && (ball.position.y < ssz.height/3) && [ball lastPlayer] == player[1]) {
			[ball strobe:dt];
		}
		if ([ball isWhite] && (ball.position.y > 2*ssz.height/3) && [ball lastPlayer] == player[0]) {
			[ball strobe:dt];
		}

		if (ball.position.x > ssz.width  || ball.position.x < 0 || 
			ball.position.y > ssz.height || ball.position.y < 0 ) 
		{
			[ball doKill];
		}
		
	}
	
	
	
	
	[self destroyBalls];
	[self destroyPowerups];
	[self destroyInvaders];
	
	//for (Fleet *fleet in fleets) [fleet tick:dt];
		
	[planet[0] tick:dt];
	[planet[1] tick:dt];
	[starfield tick:dt];
	
	[self retireParticles];
	
	// adjust ball speeds
	
	if (!bulletTime) {
		for (Ball *ball in balls) {
			b2Vec2 velocity = ball.b2dBody->GetLinearVelocity();
			// debugging
//			float vel = velocity.Length();
//			printf("ball velocity: %f \n", vel);
			if (velocity.Length() > maxSpeed) {
				velocity *= (maxSpeed/velocity.Length());
				ball.b2dBody->SetLinearVelocity(velocity);
				//printf("slowing ball \n");
			}
			else if (velocity.Length() < minSpeed) {
				velocity *= (minSpeed/velocity.Length());
				ball.b2dBody->SetLinearVelocity(velocity);
				//printf("speeding ball \n");
			}
			else if (velocity.Length() == 0) {
				float randx = arc4random() % 10;
				float randy = arc4random() % 10;
				ball.b2dBody->SetLinearVelocity(b2Vec2((randx - 5)/10, (randy - 5)/10));
			}
		}
		
	}

	// replace any nukes that have blown
	
	for (Fleet *fleet in fleets) {
		if ([fleet vacantNuke]) {
			
			// create a UFO and drop a new nuke at the vacan't nuke's position
			
			DynamicInvader *newDI = [self addSpriteBody:[DynamicInvader class] atPos:ccp(-100,-100) withForce:ccp(0,0)];
			UFO *newUFO = [[[UFO alloc] initUFO] autorelease];
			[newUFO flyTo:[fleet vacantNukePos] with: newDI];
			[fleet replaceNuke:newDI];
			[self.sheet addChild:newUFO];
		}
	}
	
	// Autoposition paddles 
	
	int randOffset = arc4random() % 100;
	randOffset -= 50;
	Ball *nearestBall = [balls lastObject];

	if ([[settings get:@"Player2Type"] isEqualToString:@"COMPUTER"] && [[GameState getCurrentState] isKindOfClass:[StatePlaying class]]) {
		// find nearest ball
		
		for (Ball *b in balls) {
			if ((b.position.y > nearestBall.position.y) && 
				(b.position.y < paddle2.position.y) && 
				(b.b2dBody->GetLinearVelocity().y > 0))
			{
				nearestBall = b;	
			}
		}
		if (nearestBall) [paddle2 moveTo:(paddle2.position.x * 2.0 + (nearestBall.position.x + nearestBall.AIOffset)) / 3.0];
	}	

	if ([[settings get:@"Player1Type"] isEqualToString:@"COMPUTER"] && [[GameState getCurrentState] isKindOfClass:[StatePlaying class]]) {
		for (Ball *b in balls) {
			if ((b.position.y < nearestBall.position.y) &&
				(b.position.y > paddle1.position.y) && 
				(b.b2dBody->GetLinearVelocity().y < 0))
			{
				nearestBall = b;	
			}
		}
		if (nearestBall) [paddle1 moveTo:(paddle1.position.x * 2.0 + (nearestBall.position.x + nearestBall.AIOffset)) / 3.0];
	}
	
	_contactListener->clearContacts();
	//printf("tick\n");
}

typedef struct {
	b2MouseJoint *mj;
	UITouch *t;
} MouseJointStruct;

static vector<MouseJointStruct> joints;

- (void)doTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//printf("-------------------------Touches Began %d\n", touchnum++);
	
	for( UITouch *touch in touches ) {
		
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		NSLog(@"touched at %5.2f, %5.2f \n", location.x, location.y);
			
		TouchedSprite *touched = nil;
		
		// check for collision with … paddle itself? define larger rect to test collision?
		if (CGRectContainsPoint([paddle1 getRect], location) && [[settings get:@"Player1Type"] isEqualToString:@"HUMAN"]) {
			
			if (!USE_DYNAMIC_PADDLES) [paddle1 moveTo: location.x];
			
			touched = [[TouchedSprite alloc] initWithSpriteBody:paddle1 touch:touch];
		}
		else if (CGRectContainsPoint([paddle2 getRect], location) && [[settings get:@"Player2Type"] isEqualToString:@"HUMAN"]) {
			
			if (!USE_DYNAMIC_PADDLES) [paddle2 moveTo: location.x];
			
			touched = [[TouchedSprite alloc] initWithSpriteBody:paddle2 touch:touch];
		}
		
		if (touched) {
			
			if (USE_DYNAMIC_PADDLES) {
				b2Body* body = touched.sb.b2dBody;
				b2MouseJointDef md;
				md.bodyA = groundBody;
				md.bodyB = body;
				md.target = b2Vec2(location.x / PTM_RATIO, location.y / PTM_RATIO);
				md.maxForce = 5000.0f * body->GetMass();
				b2MouseJoint *joint = (b2MouseJoint*)world->CreateJoint(&md);
				body->SetAwake(true);
				touched.mj = joint;
			}
			
			BOOL exists = NO;
			for (NSUInteger i=0; i< [touchedSprites count]; i++ ) {
				TouchedSprite *touchedSprite = [touchedSprites objectAtIndex:i];
				if ([touch isEqual: touchedSprite.touch]) {
					exists = YES;
					[touchedSprites replaceObjectAtIndex:i withObject:touched];
				}
			}
			
			if (!exists) [touchedSprites addObject: touched];
					
		}
		 
	}
}

- (void)doTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

	for (TouchedSprite *touchedSprite in touchedSprites) {
		for( UITouch *touch in touches ) {
			if ([touch isEqual: touchedSprite.touch]) {
				
				CGPoint location = [touch locationInView: [touch view]];
				
				location = [[CCDirector sharedDirector] convertToGL: location];
				
				if (USE_DYNAMIC_PADDLES) 
					touchedSprite.mj->SetTarget(b2Vec2(location.x / PTM_RATIO, touchedSprite.mj->GetTarget().y));
				else 
					[(Paddle*) touchedSprite.sb moveTo: location.x];
				
			}
		}
	}
}

- (void)doTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (DEBUG_SKIPLEVEL) {
		for( UITouch *touch in touches ) {
			
			CGPoint location = [touch locationInView: [touch view]];
			//if ((location.y > 400) && (location.y < 600)) {
			
			for (Fleet *fleet in fleets) {
				for (SpriteBody<Shooter> *invader in fleet.invaders) {
					[invader doHitFrom:nil withDamage:100];
				}
			}
		}
	}

	NSMutableArray *discardedItems = [NSMutableArray array];
	
	for (TouchedSprite *touched in touchedSprites) {
		for( UITouch *touch in touches ) {
			if ([touch isEqual: touched.touch]) {
				
				
				[discardedItems addObject: touched];
				
				if (touched.mj) {
					world->DestroyJoint(touched.mj);
					touched.mj = NULL;
				}
			}
		}
	}
	[touchedSprites removeObjectsInArray:discardedItems];
}

- (void) clearTouches {
	for (TouchedSprite *touchedSprite in touchedSprites) {
		if (touchedSprite.mj) {
			world->DestroyJoint(touchedSprite.mj);
		}
	}
	[touchedSprites removeAllObjects];
}

#define vec2angle(vec) (180 * atan2(-vec.y, vec.x)/M_PI + 90)

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {	
	
	if (!bulletTime) {
		effectring.rotation = vec2angle(acceleration);
		if (!self.accelNormalized) {
			baseAccel[0] = baseAccel[0]*0.9 + acceleration.x*0.1;
			baseAccel[1] = baseAccel[1]*0.9 + acceleration.y*0.1;
			baseAccel[2] = baseAccel[2]*0.9 + acceleration.z*0.1;
		}
		return;
	}
	
	self.accelNormalized = YES;
	
	b2Vec2 impulse;
	float k = 0.2;
	CGFloat accel[3] = {
		acceleration.x-baseAccel[0], 
		acceleration.y-baseAccel[1], 
		acceleration.z-baseAccel[2]};
	
	if (_IPAD) {
		impulse = b2Vec2( 0*oldImpulse.x + accel[0], oldImpulse.y * 0.0 + accel[1]);
		oldImpulse = impulse;
	}
	else {
		impulse = b2Vec2( 0*oldImpulse.x + accel[0]/2.0, 0*oldImpulse.y + accel[1]/2.0);
		oldImpulse = impulse;
	}
	
	for (Ball *ball in balls) {
		if (ball.isBulletTime) {
			b2Vec2 point( ball.position.x, ball.position.y);
			
			ball.b2dBody->ApplyLinearImpulse( impulse, point );	
		}
	}
	
	// set effect animation
	b2Vec2 effectVec = impulse;
	float32 effectMag = effectVec.Normalize();
	if (effectMag > 0.9) effectMag = 0.9;
	CCRepeatForever *action = (CCRepeatForever *)[effectring getActionByTag:EFFECT_ACTION];
	CCAnimate *animate = (CCAnimate *) [action getOther];
	animate.duration = animate.duration*(1-k)+k*0.20*(1.0-effectMag);
	//[effectring runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:effectringanim restoreOriginalFrame:NO] ]];

	float32 rotTgt = vec2angle(effectVec);
	while (rotTgt >= 360) rotTgt -= 360;
	while (rotTgt <    0) rotTgt += 360;

	if      (abs((rotTgt + 360) - effectring.rotation) < abs(rotTgt-effectring.rotation)) 
		effectring.rotation = effectring.rotation * (1-k) + (rotTgt+360) * k;
	else if (abs((rotTgt - 360) - effectring.rotation) < abs(rotTgt-effectring.rotation)) 
		effectring.rotation = effectring.rotation * (1-k) + (rotTgt-360) * k;
	else
		effectring.rotation = effectring.rotation * (1-k) + rotTgt * k;

	NSLog(@"%8.4f dur, %8.4f angle", animate.duration, effectring.rotation);
}

#pragma mark Scene entity management -------------------------------------

- (BOOL) isGameLost {
	//return FALSE;
	return [planet[0] isDead] || [planet[1] isDead];
}

- (BOOL) isGameWon {
	BOOL fleetsGone = YES;
	for (Fleet *fleet in fleets) 
		if (![fleet isDead])
			fleetsGone = NO;
	
	if (fleetsGone) {
		[fuzz stop];
	}
	return fleetsGone;
}

- (void) addFleet:(Fleet *)fleet {
	[fleets addObject:fleet];
}

- (SpriteBody *) addSpriteBody: (Class) spriteBodyClass atPos: (CGPoint) p withForce: (CGPoint) f {
	SpriteBody *sb = nil;
	NSMutableArray *array = [inactiveInvaders objectForKey:[spriteBodyClass description]];
	if ([array count] == 0) {
		sb = [spriteBodyClass spriteBodyAt: p withForce: f inWorld: world];
		//if (sb) printf("its something!");
		[self.sheet addChild:sb];
	} else {
		sb = [array objectAtIndex:0];
		printf("recycling %s\n", [[[sb class] description] UTF8String]);
		sb.position = p;
		sb.b2dBody->SetTransform(b2Vec2(p.x/PTM_RATIO, p.y/PTM_RATIO), 0);
		[self.sheet addChild:sb];
		[array removeObjectAtIndex:0];
	}
	if (sb.idle)
		[sb runAction:[CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:sb.idle restoreOriginalFrame:NO] ]];
	
	return sb;
}

- (void) showPaddles: (BOOL) isVisible {
	paddle1.visible = isVisible;
	paddle2.visible = isVisible;
	paddle1.b2dBody->SetActive(isVisible);
	paddle2.b2dBody->SetActive(isVisible);
}

+ (float) spriteDistance: (SpriteBody *) sprite1 sprite2: (SpriteBody *) sprite2 {
	int dx = (sprite1.position.x - sprite2.position.x);
	int dy = (sprite1.position.y - sprite2.position.y);
	return sqrt(dx*dx + dy*dy);
}



- (void) doExplosionAt:(CGPoint)p fromDyn:(DynamicInvader *)inv {
	AABBQueryCallback callback;
	
	b2AABB aabb;
	
	if _IPAD {
		aabb.lowerBound.Set((p.x - 40)/PTM_RATIO, (p.y - 40)/PTM_RATIO);
		aabb.upperBound.Set((p.x + 40)/PTM_RATIO, (p.y + 40)/PTM_RATIO);
	}
	else {
		aabb.lowerBound.Set((p.x - 20)/PTM_RATIO, (p.y - 20)/PTM_RATIO);
		aabb.upperBound.Set((p.x + 20)/PTM_RATIO, (p.y + 20)/PTM_RATIO);
	}
	
	world->QueryAABB(&callback, aabb);
	
	std::vector<b2Body *>::iterator pos;
	
	Ball *ball = inv.lastBall;
	
	for (pos = callback.contacts.begin();
		 pos != callback.contacts.end(); pos++) {
		SpriteBody<Shooter> *sb = (SpriteBody<Shooter> *)(*pos)->GetUserData();
		ball.combo +=1;
		if (![sb isMemberOfClass:[Ball class]]) {
			[sb doHitFrom:ball withDamage:100];
		}
	}
	
	[inv doKill];
		
	[[SimpleAudioEngine sharedEngine] playEffect:@"mine.wav"];
	
	printf("BOOM \n");
}

- (void) setDifficulty: (int) level {
	numBalls = 5 + (int) (level/5);
//	if (level > LEVELSTOMAX) {
//		maxSpeed = IMPOSSIBLEBALLSPEED;
//		minSpeed = MINBALLSPEED;
//	}
//	else {
		maxSpeed = 20; // + ((float) level / LEVELSTOMAX)*10;
		minSpeed = MINBALLSPEED;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		minSpeed = minSpeed/8.0;
		maxSpeed = maxSpeed/2.0;
	}
//	}
	
}

- (float) randBallMagnitude {
	float rand = 1.25 + (( (float) (arc4random() % 5))/5);
	//printf("randmag: %f \n", rand);
	return rand * minSpeed;
	
//	float rand = (50.0f + (arc4random() % 200))/100;
//	printf("randmag: %f \n", rand);
//	return rand;
}


- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event { 
	//if (motion == UIEventSubtypeMotionShake && [[GameState getCurrentState] isMemberOfClass: [StateMainMenu class]] ) {
		//TZCouponView *tzCouponView = [[TapZillaCoupon sharedManager] getCouponView];
		//[[[CCDirector sharedDirector] openGLView] addSubview:tzCouponView];
		//[tzCouponView motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event];
	//}
}

- (void) updateOFScores {
	BOOL p1h = [[settings get:@"Player1Type"] isEqualToString:@"HUMAN"];
	BOOL p2h = [[settings get:@"Player2Type"] isEqualToString:@"HUMAN"];

	// set high score
	int combinedHighScore = (p1h?player[0].score:0) + (p2h?player[1].score:0);
	
	
	// set maxChain record
	int combinedMaxChain = (p1h?paddle1.player.maxChain:0) + (p2h?paddle2.player.maxChain:0);
	
	
	if (_IPAD) {
		[OFHighScoreService setHighScore:combinedMaxChain forLeaderboard:@"438994" 
							   onSuccess:OFDelegate() onFailure:OFDelegate()];
		[OFHighScoreService setHighScore:combinedHighScore forLeaderboard:@"438984" 
							   onSuccess:OFDelegate() onFailure:OFDelegate()];
	}
	else {
		[OFHighScoreService setHighScore:combinedMaxChain forLeaderboard:@"552304" 
							   onSuccess:OFDelegate() onFailure:OFDelegate()];
		[OFHighScoreService setHighScore:combinedHighScore forLeaderboard:@"552294" 
							   onSuccess:OFDelegate() onFailure:OFDelegate()];
	}
	
	//check for ah-ah-ah-achievements
	
	
	// Hotballs Fireball
	if (gotFireball) {
		[OFAchievementService updateAchievement:HOT_BALLS andPercentComplete:100 andShowNotification:YES];
		//myAchievement = [[OFAchievement achievement:@"516324"] autorelease];
//		[myAchievement unlock];
	}
	
	// Ball Juggler
	if (combinedMaxChain >= 10) {
		[OFAchievementService updateAchievement:BALL_JUGGLER_10 andPercentComplete:100 andShowNotification:YES];
	}
	if (combinedMaxChain >= 20) {
		[OFAchievementService updateAchievement:BALL_JUGGLER_20 andPercentComplete:100 andShowNotification:YES];
	}
	if (combinedMaxChain >= 50) {
		[OFAchievementService updateAchievement:BALL_JUGGLER_50 andPercentComplete:100 andShowNotification:YES];
	}
	if (combinedMaxChain >= 100) {
		[OFAchievementService updateAchievement:BALL_JUGGLER_100 andPercentComplete:100 andShowNotification:YES];
	}
	
	// High as balls score
	if (combinedHighScore >= 100000) {
		[OFAchievementService updateAchievement:HIGH_AS_BALLS andPercentComplete:100 andShowNotification:YES];
	}
	
	// Ball Bouncer combo
	if ((p1h && (paddle1.player.maxCombo >= 5)) || (p2h && (paddle2.player.maxCombo >= 5))) {
		[OFAchievementService updateAchievement:BALL_BOUNCER andPercentComplete:100 andShowNotification:YES];
	}
}

- (void) setBackgroundVolume: (float) volume {
	[SimpleAudioEngine sharedEngine].backgroundMusicVolume = volume;
}

- (Ball *) closestBallTo: (CGPoint) pos maxDist: (float)maxDist {
	float dist = 100000;
	Ball *curball = nil;
	
	for (Ball *ball in balls) {
		float ndist = [Utils distanceFrom:ball.position to:pos];
		
		CGPoint balldir = [ball getDir];
		CGPoint ball2pt = CGNormalize(ccp(pos.x-ball.position.x, pos.y-ball.position.y));
		float prod = CGDotProduct(balldir, ball2pt);
		
		if ((ndist < maxDist) && [ball isWhite] && (prod > 0.5) && (ndist < dist)) 
		{
			curball = ball;
			dist = ndist;
		}
	}
	return curball;
}

- (void) terminating {

	if ([[GameState getCurrentState] isKindOfClass:[StatePlaying class]] ||
		[[GameState getCurrentState] isKindOfClass:[StatePausedMenu class]]) {
		StatePausedMenu *spm = [[[StatePausedMenu alloc] init] autorelease];
		spm.shouldClearFirst = NO;
		[GameState handleEvent:spm];
	} else {

		[[BeatSequencer getInstance] end];
		[[BeatSequencer getInstance] clearResponders];
		[[BeatSequencer getInstance] reset];
		[[BeatSequencer getInstance] clearEvents];
		[self clearScene];
		[self resetScene];
	}
		
	[self clearTouches];
	[self writeToPersist];
}

- (void) productsRequestComplete: (NSArray *) products 
{
	if ([products count] > 0) {
		SKProduct *epProduct = [products objectAtIndex:0];
		[settings set:@"EpisodesProduct" to:epProduct.productIdentifier]; 
	}
	
}

- (void) productsRequestFailed {}

@end
