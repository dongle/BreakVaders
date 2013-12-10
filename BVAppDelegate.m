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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Init the window
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// cocos2d will inherit these values
	[_window setUserInteractionEnabled:YES];
	[_window setMultipleTouchEnabled:YES];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
//	if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
//		[CCDirector setDirectorType:CCDirectorTypeDefault];
	
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
	[[CCDirector sharedDirector] attachInView:_window];
	[_window makeKeyAndVisible];
	
	[[CCDirector sharedDirector] runWithScene: (CCScene *) [PongVader scene]];
	
	[[OverlayViewController sharedController] show];
    
	[[OverlayViewController sharedController] hide];
    
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
	//[GameState handleEvent: [[[StateMainMenu alloc] init] autorelease]];
    
	PongVader *pv = [PongVader getInstance];
	
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
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
