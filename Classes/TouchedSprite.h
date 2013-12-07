//
//  TouchedSprite.h
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/28/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteBody.h"


@interface TouchedSprite : NSObject {
	UITouch *touch;
	SpriteBody *sb;
	b2MouseJoint *mj;
}

@property (nonatomic, retain) UITouch *touch;
@property (nonatomic, retain) SpriteBody *sb;
@property (readwrite, assign) b2MouseJoint *mj;

- (id) initWithSpriteBody: (SpriteBody*) s touch: (UITouch*) t;

@end
