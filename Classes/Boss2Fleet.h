//
//  Boss2Fleet.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Fleet.h"
#import "ADMBrain.h"

@interface Boss2Fleet : Fleet {
	CGPoint origin;
	CGPoint dimensions;
	CGFloat spacing;
	NSString *score;
	
	ADMBrain *brain;
}

@property (nonatomic, retain) ADMBrain *brain;

- (id) initAtOrigin: (CGPoint) atorigin 
			withDir: (CGPoint) dir
			playing: (NSString *) scoretoplay
		 difficulty: (int) level ;

- (void) pause;

@end
