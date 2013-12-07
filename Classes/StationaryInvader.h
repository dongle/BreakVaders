//
//  StationaryInvader.h
//  MultiBreakout
//
//  Created by Cole Krumbholz on 7/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Invader.h"
#import "GameSettings.h"

@interface StationaryInvader : Invader {

}

- (void) doDestroyedScore: (Ball *) ball;	

@end
