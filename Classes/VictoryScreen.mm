//
//  VictoryScreen.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/5/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "VictoryScreen.h"
#import "PongVaderScene.h"

@implementation VictoryScene
@synthesize layer = _layer;

- (id)init {
	
	if ((self = [super init])) {
		self.layer = [VictoryLayer node];
		[self addChild:_layer];
	}
	return self;
}

- (void)dealloc {
	[_layer release];
	_layer = nil;
	[super dealloc];
}

@end

@implementation VictoryLayer
@synthesize label = _label;

-(id) init
{
	if( (self=[super initWithColor:ccc4(0,0,0,255)] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		_label = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:32];
		_label.color = ccc3(255,255,255);
		_label.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:_label];
		
		[self runAction:[CCSequence actions:
						 [CCDelayTime actionWithDuration:15],
						 [CCCallFunc actionWithTarget:self selector:@selector(victoryDone)],
						 nil]];
		
	}	
	return self;
}

- (void)victoryDone {
	[[CCDirector sharedDirector] replaceScene:[PongVader scene]];
}

- (void)dealloc {
	[_label release];
	_label = nil;
	[super dealloc];
}

@end