//
//  LineFleet.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fleet.h"
#import "GameSettings.h"

#define LINEFLEET_ANIM_TIME 0.1
#define LINEFLEET_START_SIZE 5

@interface LineFleet : Fleet {
	BOOL _stationary;
	float _maxWidth;
	CGPoint _origin;
	CGPoint _direction;
	//bool lastShotUp;
}

- (id) initWithSize:(int) size 
		   andWidth:(int) width 
		   maxWidth:(int) maxwidth 
		   atOrigin:(CGPoint) origin 
		 upsideDown:(BOOL) upsidedown 
		 stationary:(BOOL) stat 
		 difficulty:(int) level 
			classes:(Class *) classes;
- (void) moveFleet;

@end
