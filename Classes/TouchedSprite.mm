//
//  TouchedSprite.mm
//  MultiBreakout
//
//  Created by Jonathan Beilin on 6/28/10.
//  Copyright 2010 Koduco Games. All rights reserved.
//

#import "TouchedSprite.h"


@implementation TouchedSprite

@synthesize touch = _touch;
@synthesize sb = _sb;
@synthesize mj = _mj;


- (id) initWithSpriteBody: (SpriteBody*) s touch: (UITouch*) t {
	
	if ((self = [super init])) { 
		_sb = [s retain];
		_touch = [t retain];
		_mj = NULL;
	} 
	
	return self;
}

- (void) dealloc {
	[_touch release];
	[_sb release];
	[super dealloc];
}

@end
