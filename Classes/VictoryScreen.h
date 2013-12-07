//
//  VictoryScreen.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/5/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface VictoryLayer : CCColorLayer {
	CCLabel *_label;
}

@property (nonatomic, retain) CCLabel *label;

@end

@interface VictoryScene : CCScene {
	VictoryLayer *_layer;
}

@property (nonatomic, retain) VictoryLayer *layer;

@end
