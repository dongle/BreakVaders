//
//  VictoryScreen.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 7/5/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface VictoryLayer : CCLayerColor {
	CCLabelTTF *_label;
}

@property (nonatomic, retain) CCLabelTTF *label;

@end

@interface VictoryScene : CCScene {
	VictoryLayer *_layer;
}

@property (nonatomic, retain) VictoryLayer *layer;

@end
