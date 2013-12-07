//
//  Player.m
//  MultiBreakout
//
//  Created by Jonathan Beilin on 8/1/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "Player.h"
#import "SettingsManager.h"
#import "PongVaderScene.h"

@implementation Player

@synthesize name, maxCombo; //chain, maxChain, maxCombo, lastLevelScore;

- (id) initWithName: (NSString *) aname {
	if ((self = [super init])) {
		self.name = aname;
//		self.chain = 0;
//		self.maxChain = 0;
	}
	return self;
}

- (void) dealloc {
	[name release];
	[super dealloc];
}

- (void) incScoreBy:(int) bonus {
	PongVader *pv = [PongVader getInstance];
	int calcScore = bonus*(1+([pv.settings getInt:self.chainKey]/SCORE_CHAINMULT));
	if (([name isEqualToString:@"player1"] && ([pv.settings getInt:@"Player1Type"] == 0)) ||
		([name isEqualToString:@"player2"] && ([pv.settings getInt:@"Player2Type"] == 0))) {
		[pv.settings inc:self.scoreKey by:calcScore];
	}
}

- (void) setLastLevelScore {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.lastLevelScoreKey toInt:[pv.settings getInt:self.scoreKey]];
}

- (void) restoreLastLevelScore {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.scoreKey toInt:[pv.settings getInt:self.lastLevelScoreKey]];
}

- (void) resetScore {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.scoreKey toInt:0];
}

- (void) resetLastLevelScore {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.lastLevelScoreKey toInt:0];
}

- (void) incChain {
	PongVader *pv = [PongVader getInstance];
	if (([name isEqualToString:@"player1"] && ([pv.settings getInt:@"Player1Type"] == 0)) ||
		([name isEqualToString:@"player2"] && ([pv.settings getInt:@"Player2Type"] == 0))) {
		[pv.settings inc:self.chainKey by:1];
		if ([pv.settings getInt:self.chainKey] > [pv.settings getInt:self.maxChainKey]) {
			[pv.settings set:self.maxChainKey toInt: [pv.settings getInt:self.chainKey]];
		}
	}
}

- (void) setLastLevelChain {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.lastLevelChainKey toInt:[pv.settings getInt:self.chainKey]];
}

- (void) resetChain {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.chainKey toInt:0];
}

- (void) resetMaxChain {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.maxChainKey toInt:0];
}

- (void) resetLastLevelChain {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.lastLevelChainKey toInt:0];
}

- (void) restoreLastLevelChain {
	PongVader *pv = [PongVader getInstance];
	[pv.settings set:self.chainKey toInt:[pv.settings getInt:self.lastLevelChainKey]];
}

- (void) resetPropsNewGame {
	[self resetChain];
	[self resetMaxChain];
	[self resetScore];
	[self resetLastLevelScore];
	[self resetLastLevelChain];
}


// keys for settings manager
- (NSString *) scoreKey {
	return [NSString stringWithFormat:@"%@_score", name];
}

- (NSString *) lastLevelScoreKey {
	return [NSString stringWithFormat:@"%@_lastLevelScore", name];
}

- (NSString *) chainKey {
	return [NSString stringWithFormat:@"%@_chain", name];
}

- (NSString *) maxChainKey {
	return [NSString stringWithFormat:@"%@_maxChain", name];
}

- (NSString *) lastLevelChainKey {
	return [NSString stringWithFormat:@"%@_lastLevelChain", name];
}

// accessors for settings manager
- (int) score {
	PongVader *pv = [PongVader getInstance];
	return [pv.settings getInt:self.scoreKey];
}

- (int) lastLevelScore {
	PongVader *pv = [PongVader getInstance];
	return [pv.settings getInt:self.lastLevelScoreKey];
}

- (int) chain {
	PongVader *pv = [PongVader getInstance];
	return [pv.settings getInt:self.chainKey];
}

- (int) maxChain {
	PongVader *pv = [PongVader getInstance];
	return [pv.settings getInt:self.maxChainKey];
}

- (int) lastLevelChain {
	PongVader *pv = [PongVader getInstance];
	return [pv.settings getInt:self.lastLevelChainKey];
}

@end
