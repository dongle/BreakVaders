//
//  BVGameKitHelper.h
//  BreakVaders
//
//  Created by Jonathan Beilin on 3/3/14.
//  Copyright (c) 2014 Jonathan Beilin. All rights reserved.
//
//  Based on some Apple sample code and some Ray Wenderlich stuff.
//  Warning: I got super lazy here; I can guarantee that I handle GameKit stuff
//           clumsily
//
//  TODO:
//      - see whether submitted achievement was successful; log failed
//        submissions and resubmit later

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

static NSString* const BVAchievementChain10 = @"BV_CHAIN_10";
static NSString* const BVAchievementChain25 = @"BV_CHAIN_25";
static NSString* const BVAchievementChain50 = @"BV_CHAIN_50";
static NSString* const BVAchievementChain100 = @"BV_CHAIN_100";

static NSString* const BVAchievementFB3 = @"BF_FB_3";
static NSString* const BVAchievementFB9 = @"BV_FB_9";

static NSString* const BVAchievementPro = @"BV_PRO";
static NSString* const BVAchievementEp1 = @"BV_EP1";
static NSString* const BVAchievementEp2 = @"BV_EP2";

@protocol BVGameKitHelperProtocol <NSObject>
@end

@interface BVGameKitHelper : NSObject

@property (nonatomic, weak) id<BVGameKitHelperProtocol> delegate;
@property (nonatomic, readonly) NSError *lastError;

+ (id) sharedGameKitHelper;

- (void) authenticatePlayer;
- (BOOL) isAuthenticated;

- (void) submitAchievementId:(NSString *)achievementId;
- (void) displayAchievements;

@end
