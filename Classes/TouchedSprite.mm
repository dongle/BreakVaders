//
//  TouchedSprite.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/28/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "TouchedSprite.h"


@implementation TouchedSprite
@synthesize touch, sb, mj;


- (id) initWithSpriteBody: (SpriteBody*) s touch: (UITouch*) t {
	
	if ((self = [super init])) { 
		sb = [s retain];
		touch = [t retain];
		mj = NULL;
	} 
	
	return self;
}

- (void) dealloc {
	[touch release];
	[sb release];
	[super dealloc];
}

@end
