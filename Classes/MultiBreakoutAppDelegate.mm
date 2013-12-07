//
//  MultiBreakoutAppDelegate.m
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/27/10.
//  Copyright Koduco Games 2010. All rights reserved.
//

#import "MultiBreakoutAppDelegate.h"
#import "cocos2d.h"
#import "PongVaderScene.h"
//#import "MultiBrickScene.h"
//#import "TapZillaCoupon.h"
#import "FlurryAPI.h"
#import "OpenFeint.h"
#import "AdLoader.h"
#import "Reachable.h"

@implementation MultiBreakoutAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[ShakeEnabledUIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:CCDirectorTypeDefault];
	
	// Use RGBA_8888 buffers
	// Default is: RGB_565 buffers
	[[CCDirector sharedDirector] setPixelFormat:kPixelFormatRGBA8888];
	
	// Create a depth buffer of 16 bits
	// Enable it if you are going to use 3D transitions or 3d objects
//	[[CCDirector sharedDirector] setDepthBufferFormat:kDepthBuffer16];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	
	// before creating any layer, set the landscape mode
	[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationPortrait];
	[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
	[[CCDirector sharedDirector] setDisplayFPS:NO];
	
	// create an openGL view inside a window
	[[CCDirector sharedDirector] attachInView:window];	
	[window makeKeyAndVisible];		
	
	[[CCDirector sharedDirector] runWithScene: (CCScene *) [PongVader scene]];
	
	//[TapZillaCoupon sharedManager];
	[FlurryAPI startSession:@"NGW3XRG21MRJVFZR1CQ7"];
	
	[FlurryAPI logEvent:@"SESSION_LENGTH" timed:YES];
	
	[[OverlayViewController sharedController] show];

	[Crittercism initWithAppID: @"4d014c1366d7872ef2000d42" andKey:@"4d014c1366d7872ef2000d42qucmrzyp" andSecret:@"9wlpmugfxcel4s3zwnoqoydteig6bqfa" andMainViewController:[OverlayViewController sharedController]];
	[[OverlayViewController sharedController] hide];
	
	[[AdLoader sharedLoader] loadAdIndex];
	[[AdLoader sharedLoader] preloadAd:[Reachable connectedToNetwork]];

	// jump into the initial state
	
	if ([[PongVader getInstance].settings getInt:@"TimesRun"] != 0) {
		[GameState handleEvent: [[[StateAd alloc] initWithHighFreq: NO nextState:[[[StateMainMenu alloc] init] autorelease]] autorelease]];
	} else {
		[GameState handleEvent: [[[StateMainMenu alloc] init] autorelease]];
	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[PongVader getInstance] terminating];	
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
	[OpenFeint applicationWillResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] stopAnimation]; // call this to make sure you don't start a second display link!
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
	[OpenFeint applicationDidBecomeActive];
	//[GameState handleEvent: [[[StateMainMenu alloc] init] autorelease]];

	PongVader *pv = [PongVader getInstance];

	[StoreObserver create];
	[[StoreObserver getInstance] addResponder:[PongVader getInstance]];
	if ([Reachable connectedToNetwork] && ![pv.settings getInt:@"EpisodesBought"])
		[[StoreObserver getInstance] requestProducts:[NSSet setWithObject:EPISODES_PRODUCT_ID]];
	
	GameState *cur = [GameState getCurrentState];
	if ([cur isKindOfClass:[StateGetReady class]] || 
		[cur isKindOfClass:[StatePlaying class]] ||
		[cur isKindOfClass:[StatePostPlaying class]] ||
		[cur isKindOfClass:[StateMainMenu class]] ||
		[cur isKindOfClass:[StateMovie class]]) {
		
		if ([pv.settings getInt:@"TimesRun"] != 0) {
			[GameState handleEvent: [[[StateAd alloc] initWithHighFreq: NO nextState:[[[StateMainMenu alloc] init] autorelease]] autorelease]];
		} else {
			[GameState handleEvent: [[[StateMainMenu alloc] init] autorelease]];
		}
	}
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
	[[PongVader getInstance] terminating];
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	//[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	[[AdLoader sharedLoader] unloadAllAds];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[AdLoader cleanup];
	
	[[StoreObserver getInstance] removeResponder:[PongVader getInstance]];
	[StoreObserver destroy];

	[[PongVader getInstance] terminating];
	[[CCDirector sharedDirector] end];
	//[OpenFeint shutdown];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end
