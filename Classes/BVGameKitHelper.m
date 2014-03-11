//
//  BVGameKitHelper.m
//  BreakVaders
//
//  Created by Jonathan Beilin on 3/3/14.
//  Copyright (c) 2014 Jonathan Beilin. All rights reserved.
//

#import "BVGameKitHelper.h"

@interface BVGameKitHelper () <GKGameCenterControllerDelegate> {
    BOOL _gameCenterFeaturesEnabled;
}
@end

@implementation BVGameKitHelper

@synthesize delegate = _delegate;
@synthesize lastError = _lastError;

#pragma mark Singleton stuff

+(id) sharedGameKitHelper {
    static BVGameKitHelper *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper =
        [[BVGameKitHelper alloc] init];
    });
    return sharedGameKitHelper;
}

#pragma mark Player Authentication

-(void) authenticatePlayer {
    
    __weak GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController,
      NSError *error) {
        
        [self setLastError:error];
        
        if (localPlayer.authenticated) {
            _gameCenterFeaturesEnabled = YES;
        } else if (viewController != nil) {
            [self presentViewController:viewController];
            _gameCenterFeaturesEnabled = YES;
        } else {
            _gameCenterFeaturesEnabled = NO;
        }
    };
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [self dismissViewController];
}

- (BOOL) isAuthenticated {
    return [GKLocalPlayer localPlayer].isAuthenticated;
}

#pragma mark - Achievements

- (void) submitAchievementId:(NSString *)achievementId {
    if (_gameCenterFeaturesEnabled) {
        GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: achievementId];
        if (achievement && [GKLocalPlayer localPlayer] != nil) {
            achievement.percentComplete = 100;
            [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error)
             {
                 if (error != nil)
                 {
                     NSLog(@"Error in reporting achievements: %@", error);
                     [self setLastError:error];
                 }
             }];
        }
    }
}

- (void) displayAchievements {
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        gameCenterController.viewState = GKGameCenterViewControllerStateAchievements;
        [self presentViewController: gameCenterController];
    }
}

#pragma mark Property setters

-(void) setLastError:(NSError*)error {
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"BVGameKitHelper ERROR: %@", [[_lastError userInfo]
                                           description]);
    }
}

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController {
    return [UIApplication
            sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc {
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES
                       completion:nil];
}

- (void)dismissViewController {
    UIViewController* rootVC = [self getRootViewController];
    [rootVC dismissViewControllerAnimated:YES completion:nil];
}

@end