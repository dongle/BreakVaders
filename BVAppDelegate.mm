//
//  BVAppDelegate.m
//  BreakVaders
//
//  Created by Jonathan Beilin on 12/5/13.
//  Copyright (c) 2013 Jonathan Beilin. All rights reserved.
//

#import "BVAppDelegate.h"
#import "OverlayViewController.h"
#import "cocos2d.h"
#import "PongVaderScene.h"

@implementation BVAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[_window setUserInteractionEnabled:YES];
	[_window setMultipleTouchEnabled:YES];
    
    CCGLView *glView = [CCGLView viewWithFrame:[_window bounds]
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    [glView setMultipleTouchEnabled:YES];
    
    CCDirectorIOS *dir = (CCDirectorIOS *) [CCDirector sharedDirector];
	
	dir.wantsFullScreenLayout = YES;
	[dir setDisplayStats:NO];
	[dir setAnimationInterval:1.0/60];
	[dir setView:glView];
	[dir setProjection:kCCDirectorProjection2D];
	if( ! [dir enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
    [dir runWithScene: (CCScene *) [PongVader scene]];
	
	// jump into the initial state
    [GameState handleEvent: [[StateMainMenu alloc] init]];
    
    _window.backgroundColor = [UIColor blackColor];
    [_window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[[PongVader getInstance] terminating];
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[PongVader getInstance] terminating];
	[[CCDirector sharedDirector] stopAnimation];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] stopAnimation]; // call this to make sure you don't start a second display link!
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
	
	GameState *cur = [GameState getCurrentState];
	if ([cur isKindOfClass:[StateGetReady class]] ||
		[cur isKindOfClass:[StatePlaying class]] ||
		[cur isKindOfClass:[StatePostPlaying class]] ||
		[cur isKindOfClass:[StateMainMenu class]] ||
		[cur isKindOfClass:[StateMovie class]]) {
		
        [GameState handleEvent: [[StateMainMenu alloc] init]];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[PongVader getInstance] terminating];
	[[CCDirector sharedDirector] end];
    CC_DIRECTOR_END();
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end