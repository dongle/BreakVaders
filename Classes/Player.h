//
//  Player.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/1/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameSettings.h"


@interface Player : NSObject {
	//int score, lastLevelScore, chain, maxChain, maxCombo;
	int maxCombo;
	NSString *name;
}

//@property (readwrite, assign) int chain, maxChain, maxCombo, lastLevelScore;

@property (readwrite, assign) NSString *name;

// keys for settings manager
@property (readonly) NSString *scoreKey;
@property (readonly) NSString *lastLevelScoreKey;
@property (readonly) NSString *chainKey;
@property (readonly) NSString *maxChainKey;
@property (readonly) NSString *lastLevelChainKey;
@property (readwrite, assign) int maxCombo;

// props for accessing settings manager
@property (readonly) int score, lastLevelScore, chain, maxChain, lastLevelChain;

- (id) initWithName: (NSString *) aname;
- (void) incScoreBy:(int) bonus;
- (void) setLastLevelScore;
- (void) restoreLastLevelScore;
- (void) resetScore;
- (void) incChain;
- (void) setLastLevelChain;
- (void) restoreLastLevelChain;
- (void) resetChain;
- (void) resetPropsNewGame;

@end
